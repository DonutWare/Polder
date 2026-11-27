import FileProvider

final class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
  private let container: NSFileProviderItemIdentifier
  private let server: ServerClient

  init(container: NSFileProviderItemIdentifier, server: ServerClient) {
    self.container = container
    self.server = server
  }

  func invalidate() {}

  func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
    guard container != .workingSet else {
      observer.finishEnumerating(upTo: nil)
      return
    }
    Task {
      do {
        let directory = try await server.entry(for: container)
        let entries = try await server.list(directory.path)
        observer.didEnumerate(entries.map { FileProviderItem($0, parent: container) })
        observer.finishEnumerating(upTo: nil)
      } catch {
        observer.finishEnumeratingWithError(ServerError.fileProviderError(error))
      }
    }
  }

  func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
    guard container == .workingSet else {
      observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
      return
    }
    Task {
      do {
        let page = try await server.changes(after: Self.cursor(of: anchor))
        let parents = ParentResolver(server: server)
        var updated: [NSFileProviderItem] = []
        var deleted: [NSFileProviderItemIdentifier] = []
        for change in page.changes {
          if change.type == "delete" {
            if let id = change.fileId { deleted.append(NSFileProviderItemIdentifier(String(id))) }
          } else if let entry = change.entry, let parent = try await parents.identifier(forDirectory: entry.parentPath) {
            updated.append(FileProviderItem(entry, parent: parent))
          }
        }
        if !deleted.isEmpty { observer.didDeleteItems(withIdentifiers: deleted) }
        if !updated.isEmpty { observer.didUpdate(updated) }
        observer.finishEnumeratingChanges(upTo: Self.anchor(of: page.cursor), moreComing: page.hasMore)
      } catch {
        observer.finishEnumeratingWithError(ServerError.fileProviderError(error))
      }
    }
  }

  func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
    guard container == .workingSet else {
      completionHandler(nil)
      return
    }
    Task {
      completionHandler((try? await server.latestCursor()).map(Self.anchor))
    }
  }

  private static func anchor(of cursor: Int64) -> NSFileProviderSyncAnchor {
    NSFileProviderSyncAnchor(Data(String(cursor).utf8))
  }

  private static func cursor(of anchor: NSFileProviderSyncAnchor) -> Int64 {
    Int64(String(decoding: anchor.rawValue, as: UTF8.self)) ?? 0
  }
}

actor ParentResolver {
  private let server: ServerClient
  private var identifiers: [String: NSFileProviderItemIdentifier?] = ["/": .rootContainer]

  init(server: ServerClient) {
    self.server = server
  }

  func identifier(forDirectory path: String) async throws -> NSFileProviderItemIdentifier? {
    if let known = identifiers[path] { return known }
    let identifier: NSFileProviderItemIdentifier?
    do {
      identifier = FileProviderItem.identifier(of: try await server.stat(path))
    } catch ServerError.notFound {
      identifier = nil
    }
    identifiers[path] = identifier
    return identifier
  }

  func item(for entry: ServerEntry) async throws -> FileProviderItem {
    guard let parent = try await identifier(forDirectory: entry.parentPath) else { throw ServerError.notFound }
    return FileProviderItem(entry, parent: parent)
  }
}
