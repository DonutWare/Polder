import FileProvider
import UniformTypeIdentifiers

final class FileProviderExtension: NSObject, NSFileProviderReplicatedExtension {
  private let domain: NSFileProviderDomain
  private let server = ServerClient()

  required init(domain: NSFileProviderDomain) {
    self.domain = domain
    super.init()
  }

  func invalidate() {}

  func item(
    for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void
  ) -> Progress {
    run(failure: { completionHandler(nil, $0) }) {
      let entry = try await self.server.entry(for: identifier)
      if identifier == .rootContainer {
        completionHandler(FileProviderItem(entry, parent: .rootContainer), nil)
      } else {
        completionHandler(try await ParentResolver(server: self.server).item(for: entry), nil)
      }
    }
  }

  func fetchContents(
    for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?,
    request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void
  ) -> Progress {
    run(failure: { completionHandler(nil, nil, $0) }) {
      let target = try self.temporaryFile()
      for attempt in 1... {
        let entry = try await self.server.entry(for: itemIdentifier)
        do {
          try await self.server.download(entry, to: target)
          completionHandler(target, try await ParentResolver(server: self.server).item(for: entry), nil)
          return
        } catch ServerError.conflict where attempt < 3 {
          continue
        }
      }
    }
  }

  func createItem(
    basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?,
    options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void
  ) -> Progress {
    run(failure: { completionHandler(nil, [], false, $0) }) {
      let parent = try await self.server.entry(for: itemTemplate.parentItemIdentifier)
      let path = Self.join(parent.path, itemTemplate.filename)
      let type = itemTemplate.contentType ?? .data
      let entry: ServerEntry
      if type.conforms(to: .folder) {
        do {
          entry = try await self.server.makeDirectory(path)
        } catch ServerError.conflict(let current?) where current.isDir {
          entry = current
        }
      } else if type.conforms(to: .symbolicLink) {
        throw ServerError.rejected
      } else {
        do {
          entry = try await self.server.upload(
            path, from: url, baseRev: 0, mtime: itemTemplate.contentModificationDate ?? nil)
        } catch ServerError.conflict(let current?) {
          throw NSError.fileProviderErrorForCollision(with: FileProviderItem(current, parent: itemTemplate.parentItemIdentifier))
        }
      }
      completionHandler(FileProviderItem(entry, parent: itemTemplate.parentItemIdentifier), [], false, nil)
    }
  }

  func modifyItem(
    _ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion,
    changedFields: NSFileProviderItemFields, contents newContents: URL?,
    options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void
  ) -> Progress {
    run(failure: { completionHandler(nil, [], false, $0) }) {
      var entry = try await self.server.entry(for: item.itemIdentifier)
      if changedFields.contains(.filename) || changedFields.contains(.parentItemIdentifier) {
        let parent = try await self.server.entry(for: item.parentItemIdentifier)
        let target = Self.join(parent.path, item.filename)
        if target != entry.path { entry = try await self.server.move(from: entry.path, to: target) }
      }
      var fetchServerContent = false
      if changedFields.contains(.contents), let newContents, !entry.isDir {
        let mtime = item.contentModificationDate ?? nil
        if FileProviderItem.content(of: version) == FileProviderItem.content(of: entry) {
          do {
            entry = try await self.server.upload(entry.path, from: newContents, baseRev: entry.rev, mtime: mtime)
          } catch ServerError.conflict(let current) {
            try await self.keepAsConflictCopy(entry.path, contents: newContents, mtime: mtime)
            if let current {
              entry = current
            } else {
              entry = try await self.server.entry(for: item.itemIdentifier)
            }
            fetchServerContent = true
          }
        } else {
          try await self.keepAsConflictCopy(entry.path, contents: newContents, mtime: mtime)
          fetchServerContent = true
        }
      }
      completionHandler(FileProviderItem(entry, parent: item.parentItemIdentifier), [], fetchServerContent, nil)
    }
  }

  func deleteItem(
    identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion,
    options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest,
    completionHandler: @escaping (Error?) -> Void
  ) -> Progress {
    run(failure: completionHandler) {
      let entry: ServerEntry
      do {
        entry = try await self.server.entry(for: identifier)
      } catch ServerError.notFound {
        completionHandler(nil)
        return
      }
      do {
        try await self.server.delete(entry.path, baseRev: entry.isDir ? -1 : FileProviderItem.revision(of: version))
      } catch ServerError.conflict {
        throw NSFileProviderError(.deletionRejected)
      }
      completionHandler(nil)
    }
  }

  func enumerator(
    for containerItemIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest
  ) throws -> NSFileProviderEnumerator {
    guard containerItemIdentifier != .trashContainer else { throw NSFileProviderError(.noSuchItem) }
    return FileProviderEnumerator(container: containerItemIdentifier, server: server)
  }

  private func keepAsConflictCopy(_ path: String, contents: URL?, mtime: Date?) async throws {
    let copy = Self.conflictPath(path, device: try await server.deviceName, at: Date())
    _ = try await server.upload(copy, from: contents, baseRev: 0, mtime: mtime)
  }

  private func temporaryFile() throws -> URL {
    guard let manager = NSFileProviderManager(for: domain) else { throw NSFileProviderError(.providerNotFound) }
    return try manager.temporaryDirectoryURL().appendingPathComponent(UUID().uuidString)
  }

  private func run(failure: @escaping (Error) -> Void, _ work: @escaping () async throws -> Void) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    let task = Task {
      do {
        try await work()
      } catch {
        failure(ServerError.fileProviderError(error))
      }
      progress.completedUnitCount = 1
    }
    progress.cancellationHandler = { task.cancel() }
    return progress
  }

  private static func join(_ directory: String, _ name: String) -> String {
    directory == "/" ? "/" + name : directory + "/" + name
  }

  private static func conflictPath(_ path: String, device: String, at date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HHmm"
    let suffix = " (conflict \(device) \(formatter.string(from: date)))"
    let directory = (path as NSString).deletingLastPathComponent
    let name = (path as NSString).lastPathComponent
    let extensionStart = name.range(of: ".", options: .backwards)?.lowerBound
    let renamed: String
    if let extensionStart, extensionStart > name.startIndex {
      renamed = name[..<extensionStart] + suffix + name[extensionStart...]
    } else {
      renamed = name + suffix
    }
    return join(directory.isEmpty ? "/" : directory, renamed)
  }
}
