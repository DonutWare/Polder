import FileProvider
import Foundation

struct ServerEntry: Decodable {
  let id: Int64
  let path: String
  let name: String
  let isDir: Bool
  let size: Int64
  let mtime: Date
  let rev: Int64
  let hash: String

  static let root = ServerEntry(
    id: 0, path: "/", name: "Polder", isDir: true, size: 0, mtime: Date(timeIntervalSince1970: 0), rev: 0, hash: "")

  var parentPath: String {
    let parent = (path as NSString).deletingLastPathComponent
    return parent.isEmpty ? "/" : parent
  }
}

struct ServerChange: Decodable {
  let type: String
  let path: String
  let fileId: Int64?
  let entry: ServerEntry?
}

struct ServerChangePage: Decodable {
  let changes: [ServerChange]
  let cursor: Int64
  let hasMore: Bool
}

enum ServerError: Error {
  case signedOut
  case notFound
  case conflict(current: ServerEntry?)
  case rejected
  case quotaExceeded
  case status(Int)

  static func fileProviderError(_ error: Error) -> Error {
    switch error {
    case ServerError.signedOut:
      return NSFileProviderError(.notAuthenticated)
    case ServerError.notFound:
      return NSFileProviderError(.noSuchItem)
    case ServerError.quotaExceeded:
      return NSFileProviderError(.insufficientQuota)
    case ServerError.rejected:
      if #available(macOS 13.0, *) { return NSFileProviderError(.excludedFromSync) }
      return NSFileProviderError(.cannotSynchronize)
    case let urlError as URLError where urlError.code == .cancelled:
      return CocoaError(.userCancelled)
    case is URLError:
      return NSFileProviderError(.serverUnreachable)
    case is CancellationError:
      return CocoaError(.userCancelled)
    case let providerError as NSFileProviderError:
      return providerError
    default:
      return NSFileProviderError(.cannotSynchronize)
    }
  }
}

actor ServerClient {
  private let session = URLSession(configuration: .ephemeral)
  private var account: ProviderAccount?
  private var refreshing: Task<Void, Error>?

  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let text = try decoder.singleValueContainer().decode(String.self)
      guard let date = parseDate(text) else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "not a date: \(text)"))
      }
      return date
    }
    return decoder
  }()

  var deviceName: String {
    get throws { try signedIn().deviceName }
  }

  func entry(for identifier: NSFileProviderItemIdentifier) async throws -> ServerEntry {
    if identifier == .rootContainer { return .root }
    guard let id = Int64(identifier.rawValue) else { throw ServerError.notFound }
    let response: ResolveResponse = try await json(
      "POST", "/files/resolve", body: try JSONEncoder().encode(["ids": [id]]))
    guard let entry = response.entries.first else { throw ServerError.notFound }
    return entry
  }

  func stat(_ path: String) async throws -> ServerEntry {
    if path == "/" { return .root }
    return try await json("GET", "/files/stat", query: ["path": path])
  }

  func list(_ path: String) async throws -> [ServerEntry] {
    let listing: ListResponse = try await json("GET", "/files/list", query: ["path": path])
    return listing.entries
  }

  func changes(after cursor: Int64) async throws -> ServerChangePage {
    try await json("GET", "/sync/changes", query: ["cursor": String(cursor)])
  }

  func latestCursor() async throws -> Int64 {
    try await changes(after: -1).cursor
  }

  func download(_ entry: ServerEntry, to target: URL) async throws {
    var request = try request("GET", "/files/content", query: ["path": entry.path])
    request.setValue("\"\(entry.rev)\"", forHTTPHeaderField: "If-Match")
    let (location, response) = try await authorized(request) { try await self.session.download(for: $0) }
    try check(response, data: nil)
    try? FileManager.default.removeItem(at: target)
    try FileManager.default.moveItem(at: location, to: target)
  }

  func upload(_ path: String, from source: URL?, baseRev: Int64, mtime: Date?) async throws -> ServerEntry {
    var query = ["path": path, "baseRev": String(baseRev)]
    if let mtime { query["mtime"] = ISO8601DateFormatter().string(from: mtime) }
    var request = try request("PUT", "/files/content", query: query)
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    let (data, response) = try await authorized(request) { request in
      if let source { return try await self.session.upload(for: request, fromFile: source) }
      return try await self.session.upload(for: request, from: Data())
    }
    try check(response, data: data)
    return try Self.decoder.decode(ServerEntry.self, from: data)
  }

  func makeDirectory(_ path: String) async throws -> ServerEntry {
    try await json("POST", "/files/mkdir", body: try JSONEncoder().encode(["path": path]))
  }

  func move(from source: String, to target: String) async throws -> ServerEntry {
    try await json("POST", "/files/move", body: try JSONEncoder().encode(["from": source, "to": target]))
  }

  func delete(_ path: String, baseRev: Int64) async throws {
    let request = try request("DELETE", "/files", query: ["path": path, "baseRev": String(baseRev)])
    let (data, response) = try await authorized(request) { try await self.session.data(for: $0) }
    if (response as? HTTPURLResponse)?.statusCode == 404 { return }
    try check(response, data: data)
  }

  private func json<Result: Decodable>(
    _ method: String, _ path: String, query: [String: String] = [:], body: Data? = nil
  ) async throws -> Result {
    var request = try request(method, path, query: query)
    if let body {
      request.httpBody = body
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    let (data, response) = try await authorized(request) { try await self.session.data(for: $0) }
    try check(response, data: data)
    return try Self.decoder.decode(Result.self, from: data)
  }

  private func request(_ method: String, _ path: String, query: [String: String]) throws -> URLRequest {
    var base = try signedIn().serverUrl
    while base.hasSuffix("/") { base.removeLast() }
    guard var components = URLComponents(string: base + "/api/v1" + path) else { throw ServerError.signedOut }
    if !query.isEmpty {
      components.queryItems = query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
      components.percentEncodedQuery = components.percentEncodedQuery?
        .replacingOccurrences(of: "+", with: "%2B")
    }
    guard let url = components.url else { throw ServerError.signedOut }
    var request = URLRequest(url: url)
    request.httpMethod = method
    return request
  }

  private func authorized<Result>(
    _ request: URLRequest, perform: (URLRequest) async throws -> (Result, URLResponse)
  ) async throws -> (Result, URLResponse) {
    let token = try signedIn().accessToken
    var signed = request
    signed.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let first = try await perform(signed)
    guard (first.1 as? HTTPURLResponse)?.statusCode == 401 else { return first }
    try await refresh(replacing: token)
    signed.setValue("Bearer \(try signedIn().accessToken)", forHTTPHeaderField: "Authorization")
    return try await perform(signed)
  }

  private func refresh(replacing staleToken: String) async throws {
    if try signedIn().accessToken != staleToken { return }
    if let refreshing { return try await refreshing.value }
    let task = Task { try await self.exchangeRefreshToken() }
    refreshing = task
    defer { refreshing = nil }
    try await task.value
  }

  private func exchangeRefreshToken() async throws {
    var current = try signedIn()
    var request = try request("POST", "/auth/refresh", query: [:])
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(["refreshToken": current.refreshToken, "deviceName": current.deviceName])
    let (data, response) = try await session.data(for: request)
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    if status == 401 || status == 403 {
      ProviderAccountStore.remove()
      account = nil
      throw ServerError.signedOut
    }
    try check(response, data: data)
    let tokens = try Self.decoder.decode(TokenPair.self, from: data)
    current.accessToken = tokens.accessToken
    current.refreshToken = tokens.refreshToken
    try ProviderAccountStore.save(current)
    account = current
  }

  private func signedIn() throws -> ProviderAccount {
    if let account { return account }
    guard let stored = ProviderAccountStore.load() else { throw ServerError.signedOut }
    account = stored
    return stored
  }

  private func check(_ response: URLResponse, data: Data?) throws {
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    switch status {
    case 200..<300:
      return
    case 401:
      throw ServerError.signedOut
    case 404:
      throw ServerError.notFound
    case 409, 412:
      let current = data.flatMap { try? Self.decoder.decode(ErrorResponse.self, from: $0) }?.current
      throw ServerError.conflict(current: current)
    case 400, 403:
      throw ServerError.rejected
    case 507:
      throw ServerError.quotaExceeded
    default:
      throw ServerError.status(status)
    }
  }

  private static func parseDate(_ text: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    guard let dot = text.firstIndex(of: ".") else {
      formatter.formatOptions = [.withInternetDateTime]
      return formatter.date(from: text)
    }
    let fractionEnd = text[dot...].dropFirst().firstIndex { !$0.isNumber } ?? text.endIndex
    let digits = text[text.index(after: dot)..<fractionEnd].prefix(3)
    let trimmed = String(text[..<dot]) + "." + digits.padding(toLength: 3, withPad: "0", startingAt: 0)
      + String(text[fractionEnd...])
    return formatter.date(from: trimmed)
  }
}

private struct ResolveResponse: Decodable {
  let entries: [ServerEntry]
}

private struct ListResponse: Decodable {
  let entries: [ServerEntry]
}

private struct ErrorResponse: Decodable {
  let current: ServerEntry?
}

private struct TokenPair: Decodable {
  let accessToken: String
  let refreshToken: String
}
