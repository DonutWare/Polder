import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
  private var titlebarChannel: FlutterMethodChannel?
  private var wallpaperChannel: FlutterMethodChannel?
  private var finderLocation: FinderLocation?
  private var launchAtLogin: LaunchAtLogin?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // The app draws the whole window, also under the title bar, which
    // stays for dragging, double-click to zoom and the window buttons. The
    // app keeps its content clear of it (lib/widgets/layout/window_titlebar.dart).
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    styleMask.insert(.fullSizeContentView)

    let channel = FlutterMethodChannel(
      name: "polder/titlebar", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "height":
        result(self?.titlebarHeight ?? 0)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    titlebarChannel = channel

    let wallpaper = FlutterMethodChannel(
      name: "polder/wallpaper", binaryMessenger: flutterViewController.engine.binaryMessenger)
    wallpaper.setMethodCallHandler { call, result in
      guard call.method == "set", let path = (call.arguments as? [String: Any])?["path"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let image = URL(fileURLWithPath: path)
        for screen in NSScreen.screens {
          try NSWorkspace.shared.setDesktopImageURL(image, for: screen, options: [:])
        }
        result(nil)
      } catch {
        result(FlutterError(code: "wallpaper", message: error.localizedDescription, details: nil))
      }
    }
    wallpaperChannel = wallpaper
    finderLocation = FinderLocation(messenger: flutterViewController.engine.binaryMessenger)
    launchAtLogin = LaunchAtLogin(messenger: flutterViewController.engine.binaryMessenger)

    NotificationCenter.default.addObserver(
      forName: NSWindow.willEnterFullScreenNotification, object: self, queue: .main
    ) { [weak self] _ in
      self?.titlebarChannel?.invokeMethod("heightChanged", arguments: 0.0)
    }
    NotificationCenter.default.addObserver(
      forName: NSWindow.willExitFullScreenNotification, object: self, queue: .main
    ) { [weak self] _ in
      self?.titlebarChannel?.invokeMethod("heightChanged", arguments: MainFlutterWindow.standardTitlebarHeight)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }

  func reveal() {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    makeKeyAndOrderFront(nil)
  }

  private static var standardTitlebarHeight: Double {
    Double(NSWindow.frameRect(forContentRect: .zero, styleMask: [.titled]).height)
  }

  private var titlebarHeight: Double {
    styleMask.contains(.fullScreen) ? 0 : MainFlutterWindow.standardTitlebarHeight
  }
}
