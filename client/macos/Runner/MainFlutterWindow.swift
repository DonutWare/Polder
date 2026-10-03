import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var titlebarChannel: FlutterMethodChannel?

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
      name: "nomad/titlebar", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "height":
        result(self?.titlebarHeight ?? 0)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    titlebarChannel = channel

    // Full screen hides the title bar until the pointer reaches the top.
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

  /// The height of a regular title bar, which the content now extends under.
  private static var standardTitlebarHeight: Double {
    Double(NSWindow.frameRect(forContentRect: .zero, styleMask: [.titled]).height)
  }

  private var titlebarHeight: Double {
    styleMask.contains(.fullScreen) ? 0 : MainFlutterWindow.standardTitlebarHeight
  }
}
