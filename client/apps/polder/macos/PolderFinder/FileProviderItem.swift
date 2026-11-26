import FileProvider
import UniformTypeIdentifiers

final class FileProviderItem: NSObject, NSFileProviderItem {
  let entry: ServerEntry
  let parentItemIdentifier: NSFileProviderItemIdentifier

  init(_ entry: ServerEntry, parent: NSFileProviderItemIdentifier) {
    self.entry = entry
    self.parentItemIdentifier = parent
  }

  static func identifier(of entry: ServerEntry) -> NSFileProviderItemIdentifier {
    entry.path == "/" ? .rootContainer : NSFileProviderItemIdentifier(String(entry.id))
  }

  static func revision(of version: NSFileProviderItemVersion) -> Int64 {
    Int64(String(decoding: version.metadataVersion, as: UTF8.self)) ?? 0
  }

  static func content(of version: NSFileProviderItemVersion) -> String {
    String(decoding: version.contentVersion, as: UTF8.self)
  }

  static func content(of entry: ServerEntry) -> String {
    entry.hash.isEmpty ? String(entry.rev) : entry.hash
  }

  var itemIdentifier: NSFileProviderItemIdentifier { Self.identifier(of: entry) }

  var filename: String { entry.name }

  var contentType: UTType {
    if entry.isDir { return .folder }
    return UTType(filenameExtension: (entry.name as NSString).pathExtension) ?? .data
  }

  var documentSize: NSNumber? { entry.isDir ? nil : NSNumber(value: entry.size) }

  var contentModificationDate: Date? { entry.mtime }

  var creationDate: Date? { entry.mtime }

  var capabilities: NSFileProviderItemCapabilities {
    if entry.isDir {
      return [.allowsReading, .allowsRenaming, .allowsReparenting, .allowsDeleting, .allowsAddingSubItems,
              .allowsContentEnumerating]
    }
    return [.allowsReading, .allowsWriting, .allowsRenaming, .allowsReparenting, .allowsDeleting]
  }

  var itemVersion: NSFileProviderItemVersion {
    NSFileProviderItemVersion(
      contentVersion: Data(Self.content(of: entry).utf8),
      metadataVersion: Data(String(entry.rev).utf8))
  }
}
