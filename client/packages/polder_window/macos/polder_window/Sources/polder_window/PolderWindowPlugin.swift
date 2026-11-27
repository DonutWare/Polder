import Cocoa
import FlutterMacOS

public class PolderWindowPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private let registrar: FlutterPluginRegistrar
  private var window: NSWindow?
  private var doubleClickMonitor: Any?

  deinit {
    if let doubleClickMonitor { NSEvent.removeMonitor(doubleClickMonitor) }
  }

  private init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
    self.channel = channel
    self.registrar = registrar
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "polder/titlebar", binaryMessenger: registrar.messenger)
    let plugin = PolderWindowPlugin(channel: channel, registrar: registrar)
    registrar.addMethodCallDelegate(plugin, channel: channel)
    plugin.drawUnderTitlebar()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "height":
      drawUnderTitlebar()
      result(titlebarHeight)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func drawUnderTitlebar() {
    guard window == nil, let window = registrar.view?.window else { return }
    self.window = window
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.styleMask.insert(.fullSizeContentView)
    let center = NotificationCenter.default
    center.addObserver(forName: NSWindow.willEnterFullScreenNotification, object: window, queue: .main) {
      [weak self] _ in
      self?.channel.invokeMethod("heightChanged", arguments: 0.0)
    }
    center.addObserver(forName: NSWindow.willExitFullScreenNotification, object: window, queue: .main) {
      [weak self] _ in
      self?.channel.invokeMethod("heightChanged", arguments: PolderWindowPlugin.standardTitlebarHeight)
    }
    // The Flutter view covers the titlebar, so its double-clicks never reach the native titlebar.
    doubleClickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
      self?.handleTitlebarDoubleClick(event)
      return event
    }
  }

  private func handleTitlebarDoubleClick(_ event: NSEvent) {
    guard let window, event.window === window, event.clickCount == 2 else { return }
    let location = event.locationInWindow
    guard location.y > window.contentLayoutRect.maxY else { return }
    if let frameView = window.contentView?.superview, frameView.hitTest(location) is NSControl { return }
    switch PolderWindowPlugin.doubleClickAction {
    case "Minimize": window.performMiniaturize(nil)
    case "None": break
    default: window.performZoom(nil)
    }
  }

  /// The "Double-click a window's title bar to" setting from System Settings › Desktop & Dock.
  private static var doubleClickAction: String {
    let defaults = UserDefaults.standard
    if let action = defaults.string(forKey: "AppleActionOnDoubleClick") { return action }
    return defaults.bool(forKey: "AppleMiniaturizeOnDoubleClick") ? "Minimize" : "Maximize"
  }

  private var titlebarHeight: Double {
    guard let window else { return 0 }
    return window.styleMask.contains(.fullScreen) ? 0 : PolderWindowPlugin.standardTitlebarHeight
  }

  private static var standardTitlebarHeight: Double {
    Double(NSWindow.frameRect(forContentRect: .zero, styleMask: [.titled]).height)
  }
}
