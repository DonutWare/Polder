import Foundation

struct ProviderAccount: Codable {
  var accountId: String
  var serverUrl: String
  var deviceName: String
  var accessToken: String
  var refreshToken: String
}

enum ProviderAccountStore {
  private static var fileURL: URL? {
    guard let group = Bundle.main.object(forInfoDictionaryKey: "PolderAppGroup") as? String,
      let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
    else { return nil }
    return container.appendingPathComponent("account.json")
  }

  static func load() -> ProviderAccount? {
    guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(ProviderAccount.self, from: data)
  }

  static func save(_ account: ProviderAccount) throws {
    guard let url = fileURL else { throw CocoaError(.fileNoSuchFile) }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try JSONEncoder().encode(account).write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
  }

  static func remove() {
    guard let url = fileURL else { return }
    try? FileManager.default.removeItem(at: url)
  }
}
