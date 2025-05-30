import Flutter
import UIKit
import GoogleMaps  // لازم تضيف الاستيراد ده

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    GMSServices.provideAPIKey("AIzaSyCE8Z_S9GkPrz0_cvEHSF2j_UMIUiJgud8")  // دي خطوة مهمة

        // 2) إعداد قناة لتصفير البادج
    let controller = window?.rootViewController as! FlutterViewController
    let badgeChannel = FlutterMethodChannel(
      name: "app.badge",
      binaryMessenger: controller.binaryMessenger
    )
    badgeChannel.setMethodCallHandler { call, result in
      if call.method == "clearBadge" {
        UIApplication.shared.applicationIconBadgeNumber = 0
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
