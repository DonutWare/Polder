import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
  private var wallpaperChannel: FlutterMethodChannel?
  private var finderLocation: FinderLocation?
  private var launchAtLogin: LaunchAtLogin?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

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
}
