import FlutterMacOS
import ServiceManagement

final class LaunchAtLogin {
  private let channel: FlutterMethodChannel
  private var launchedAtLogin = false
  private var observer: NSObjectProtocol?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "polder/launchAtLogin", binaryMessenger: messenger)
    observer = NotificationCenter.default.addObserver(
      forName: NSApplication.didFinishLaunchingNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.launchedAtLogin = LaunchAtLogin.currentEventIsLoginLaunch
    }
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "launchedAtLogin":
        result(self?.launchedAtLogin ?? false)
      case "enabled":
        guard #available(macOS 13.0, *) else { return result(nil) }
        result(LaunchAtLogin.isEnabled)
      case "setEnabled":
        guard #available(macOS 13.0, *) else { return result(nil) }
        result(LaunchAtLogin.setEnabled(call.arguments as? Bool ?? false))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  deinit {
    if let observer { NotificationCenter.default.removeObserver(observer) }
  }

  private static var currentEventIsLoginLaunch: Bool {
    let event = NSAppleEventManager.shared().currentAppleEvent
    return event?.eventID == kAEOpenApplication
      && event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
  }

  @available(macOS 13.0, *)
  private static var isEnabled: Bool {
    switch SMAppService.mainApp.status {
    case .enabled, .requiresApproval: return true
    default: return false
    }
  }

  @available(macOS 13.0, *)
  private static func setEnabled(_ enabled: Bool) -> Any? {
    do {
      if enabled {
        if SMAppService.mainApp.status != .enabled { try SMAppService.mainApp.register() }
      } else {
        try SMAppService.mainApp.unregister()
      }
      return nil
    } catch {
      return FlutterError(code: "launch_at_login", message: error.localizedDescription, details: nil)
    }
  }
}
