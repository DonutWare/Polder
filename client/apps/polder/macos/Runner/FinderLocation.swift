import FileProvider
import FlutterMacOS

enum DriveFinder {
  static let changedNotification = "org.knaapen.polder.drive.finder.changed"

  static var isConnected: Bool {
    guard let group = Bundle.main.object(forInfoDictionaryKey: "PolderAppGroup") as? String,
      let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
    else { return false }
    return FileManager.default.fileExists(atPath: container.appendingPathComponent("drive-finder.account.json").path)
  }
}

final class FinderLocation {
  private static let identifier = NSFileProviderDomainIdentifier(rawValue: "polder")

  private let channel: FlutterMethodChannel
  private var observer: NSObjectProtocol?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "polder/file_browser", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      FinderLocation.handle(call) { value in DispatchQueue.main.async { result(value) } }
    }
    observer = NotificationCenter.default.addObserver(
      forName: NSNotification.Name("NSFileProviderDomainDidChange"), object: nil, queue: .main
    ) { [weak self] _ in
      self?.announceChange()
    }
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      Unmanaged.passUnretained(self).toOpaque(),
      { _, observer, _, _, _ in
        guard let observer else { return }
        let location = Unmanaged<FinderLocation>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async { location.announceChange() }
      },
      DriveFinder.changedNotification as CFString,
      nil,
      .deliverImmediately
    )
  }

  deinit {
    if let observer { NotificationCenter.default.removeObserver(observer) }
    CFNotificationCenterRemoveEveryObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), Unmanaged.passUnretained(self).toOpaque())
  }

  private func announceChange() {
    channel.invokeMethod("changed", arguments: nil)
  }

  private static func handle(_ call: FlutterMethodCall, reply: @escaping (Any?) -> Void) {
    switch call.method {
    case "enabled":
      NSFileProviderManager.getDomainsWithCompletionHandler { domains, _ in
        reply(domains.first { $0.identifier == identifier }?.userEnabled)
      }
    case "connectedAccount":
      reply(ProviderAccountStore.load()?.accountId)
    case "handedOff":
      reply(DriveFinder.isConnected)
    case "connect":
      guard let arguments = call.arguments as? [String: String],
        let account = account(from: arguments),
        let displayName = arguments["displayName"]
      else {
        reply(FlutterError(code: "invalid_arguments", message: "connect needs an account and a display name", details: nil))
        return
      }
      connect(account, displayName: displayName, reply: reply)
    case "disconnect":
      let previous = ProviderAccountStore.load()
      ProviderAccountStore.remove()
      removeDomains { reply(previous.map(revocation)) }
    case "signal":
      NSFileProviderManager(for: NSFileProviderDomain(identifier: identifier, displayName: ""))?
        .signalEnumerator(for: .workingSet) { _ in }
      reply(nil)
    default:
      reply(FlutterMethodNotImplemented)
    }
  }

  private static func connect(_ account: ProviderAccount, displayName: String, reply: @escaping (Any?) -> Void) {
    let previous = ProviderAccountStore.load()
    let register = {
      do {
        try ProviderAccountStore.save(account)
      } catch {
        reply(failure(error))
        return
      }
      NSFileProviderManager.add(NSFileProviderDomain(identifier: identifier, displayName: displayName)) { error in
        if let error {
          reply(failure(error))
          return
        }
        NSFileProviderManager(for: NSFileProviderDomain(identifier: identifier, displayName: displayName))?
          .signalEnumerator(for: .workingSet) { _ in }
        reply(previous.map(revocation))
      }
    }
    if let previous, previous.accountId != account.accountId {
      removeDomains(then: register)
    } else {
      register()
    }
  }

  private static func removeDomains(then done: @escaping () -> Void) {
    NSFileProviderManager.getDomainsWithCompletionHandler { domains, _ in
      let ours = domains.filter { $0.identifier == identifier }
      guard !ours.isEmpty else {
        done()
        return
      }
      let group = DispatchGroup()
      for domain in ours {
        group.enter()
        NSFileProviderManager.remove(domain, mode: .preserveDirtyUserData) { _, _ in group.leave() }
      }
      group.notify(queue: .main, execute: done)
    }
  }

  private static func account(from arguments: [String: String]) -> ProviderAccount? {
    guard let accountId = arguments["accountId"],
      let serverUrl = arguments["serverUrl"],
      let deviceName = arguments["deviceName"],
      let accessToken = arguments["accessToken"],
      let refreshToken = arguments["refreshToken"]
    else { return nil }
    return ProviderAccount(
      accountId: accountId, serverUrl: serverUrl, deviceName: deviceName,
      accessToken: accessToken, refreshToken: refreshToken)
  }

  private static func revocation(_ account: ProviderAccount) -> [String: String] {
    ["serverUrl": account.serverUrl, "refreshToken": account.refreshToken]
  }

  private static func failure(_ error: Error) -> FlutterError {
    FlutterError(code: "finder_location", message: error.localizedDescription, details: nil)
  }
}
