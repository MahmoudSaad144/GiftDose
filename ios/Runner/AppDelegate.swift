import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var window: UIWindow?  // أضفنا الـ window هنا

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. إعداد Firebase
    FirebaseApp.configure()
    // 2. إعداد Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyCE8Z_S9GkPrz0_cvEHSF2j_UMIUiJgud8")
    
    // 3. إنشاء الـ UIWindow وتثبيت FlutterViewController كـ root
    window = UIWindow(frame: UIScreen.main.bounds)
    let flutterVC = FlutterViewController()
    // 4. تسجيل كل البلجنز مع الـ FlutterViewController
    GeneratedPluginRegistrant.register(with: flutterVC)
    window?.rootViewController = flutterVC
    window?.makeKeyAndVisible()

    // 5. استدعاء الـ super ويرجع true لو كل حاجة تمام
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
