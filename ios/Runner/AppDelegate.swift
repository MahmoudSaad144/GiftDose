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
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
