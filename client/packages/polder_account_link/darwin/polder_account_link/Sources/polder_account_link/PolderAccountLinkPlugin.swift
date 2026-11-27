import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#else
  import FlutterMacOS
#endif

public class PolderAccountLinkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var observedName: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let plugin = PolderAccountLinkPlugin()
    let methods = FlutterMethodChannel(name: "polder/account_link", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(plugin, channel: methods)
    let events = FlutterEventChannel(name: "polder/account_link/changes", binaryMessenger: messenger)
    events.setStreamHandler(plugin)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [:]
    let namespace = arguments["namespace"] as? String ?? ""
    do {
      switch call.method {
      case "read":
        result(try SharedAccountStore.read(namespace: namespace))
      case "write":
        try SharedAccountStore.write(namespace: namespace, json: arguments["json"] as? String ?? "")
        Self.announceChange(namespace: namespace)
        result(nil)
      case "remove":
        try SharedAccountStore.remove(namespace: namespace)
        Self.announceChange(namespace: namespace)
        result(nil)
      case "isInstalled":
        result(CompanionLauncher.isInstalled(scheme: arguments["scheme"] as? String))
      case "open":
        CompanionLauncher.open(scheme: arguments["scheme"] as? String, completion: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    stopObserving()
    guard let namespace = arguments as? String else { return nil }
    let name = Self.changeNotificationName(namespace: namespace)
    sink = events
    observedName = name
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      Unmanaged.passUnretained(self).toOpaque(),
      { _, observer, _, _, _ in
        guard let observer else { return }
        let plugin = Unmanaged<PolderAccountLinkPlugin>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async { plugin.sink?(true) }
      },
      name as CFString,
      nil,
      .deliverImmediately
    )
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopObserving()
    return nil
  }

  private func stopObserving() {
    if let observedName {
      CFNotificationCenterRemoveObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        Unmanaged.passUnretained(self).toOpaque(),
        CFNotificationName(observedName as CFString),
        nil
      )
    }
    observedName = nil
    sink = nil
  }

  private static func changeNotificationName(namespace: String) -> String { "\(namespace).account.changed" }

  private static func announceChange(namespace: String) {
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(changeNotificationName(namespace: namespace) as CFString),
      nil,
      nil,
      true
    )
  }
}

enum SharedAccountError: LocalizedError {
  case missingGroup
  case keychain(OSStatus)

  var errorDescription: String? {
    switch self {
    case .missingGroup: return "The shared Polder account group is not configured for this app"
    case .keychain(let status): return "Keychain error \(status)"
    }
  }
}

#if os(iOS)
  enum SharedAccountStore {
    private static var accessGroup: String? {
      Bundle.main.object(forInfoDictionaryKey: "PolderKeychainGroup") as? String
    }

    private static func query(namespace: String) throws -> [String: Any] {
      guard let accessGroup, !accessGroup.isEmpty else { throw SharedAccountError.missingGroup }
      return [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: namespace,
        kSecAttrAccount as String: "account",
        kSecAttrAccessGroup as String: accessGroup,
      ]
    }

    static func read(namespace: String) throws -> String? {
      var lookup = try query(namespace: namespace)
      lookup[kSecReturnData as String] = true
      lookup[kSecMatchLimit as String] = kSecMatchLimitOne
      var item: CFTypeRef?
      let status = SecItemCopyMatching(lookup as CFDictionary, &item)
      if status == errSecItemNotFound { return nil }
      guard status == errSecSuccess, let data = item as? Data else { throw SharedAccountError.keychain(status) }
      return String(data: data, encoding: .utf8)
    }

    static func write(namespace: String, json: String) throws {
      let base = try query(namespace: namespace)
      let data = Data(json.utf8)
      let update: [String: Any] = [
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
      ]
      let status = SecItemUpdate(base as CFDictionary, update as CFDictionary)
      if status == errSecSuccess { return }
      guard status == errSecItemNotFound else { throw SharedAccountError.keychain(status) }
      let added = SecItemAdd(base.merging(update) { _, new in new } as CFDictionary, nil)
      guard added == errSecSuccess else { throw SharedAccountError.keychain(added) }
    }

    static func remove(namespace: String) throws {
      let status = SecItemDelete(try query(namespace: namespace) as CFDictionary)
      guard status == errSecSuccess || status == errSecItemNotFound else { throw SharedAccountError.keychain(status) }
    }
  }

  enum CompanionLauncher {
    private static func url(_ scheme: String?) -> URL? {
      guard let scheme, !scheme.isEmpty else { return nil }
      return URL(string: "\(scheme)://")
    }

    static func isInstalled(scheme: String?) -> Bool {
      guard let url = url(scheme) else { return false }
      return UIApplication.shared.canOpenURL(url)
    }

    static func open(scheme: String?, completion: @escaping FlutterResult) {
      guard let url = url(scheme) else { return completion(false) }
      UIApplication.shared.open(url) { opened in completion(opened) }
    }
  }
#else
  enum SharedAccountStore {
    private static func fileURL(namespace: String) throws -> URL {
      guard let group = Bundle.main.object(forInfoDictionaryKey: "PolderAppGroup") as? String,
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
      else { throw SharedAccountError.missingGroup }
      return container.appendingPathComponent("\(namespace).account.json")
    }

    static func read(namespace: String) throws -> String? {
      let url = try fileURL(namespace: namespace)
      guard let data = try? Data(contentsOf: url) else { return nil }
      return String(data: data, encoding: .utf8)
    }

    static func write(namespace: String, json: String) throws {
      let url = try fileURL(namespace: namespace)
      try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      try Data(json.utf8).write(to: url, options: .atomic)
      try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }

    static func remove(namespace: String) throws {
      let url = try fileURL(namespace: namespace)
      guard FileManager.default.fileExists(atPath: url.path) else { return }
      try FileManager.default.removeItem(at: url)
    }
  }

  enum CompanionLauncher {
    static func isInstalled(scheme: String?) -> Bool { false }

    static func open(scheme: String?, completion: @escaping FlutterResult) { completion(false) }
  }
#endif
