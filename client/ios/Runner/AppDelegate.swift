import Flutter
import UIKit
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var documentScannerChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DocumentScannerAccent") else { return }
    let channel = FlutterMethodChannel(name: "nomad/document_scanner", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setAccent":
        guard let args = call.arguments as? [String: Int], let light = args["light"], let dark = args["dark"] else {
          result(FlutterError(code: "bad_args", message: nil, details: nil))
          return
        }
        let accent = UIColor { traits in
          UIColor(argb: traits.userInterfaceStyle == .dark ? dark : light)
        }
        UIView.appearance(whenContainedInInstancesOf: [VNDocumentCameraViewController.self]).tintColor = accent
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    documentScannerChannel = channel
  }
}

private extension UIColor {
  convenience init(argb: Int) {
    self.init(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255
    )
  }
}
