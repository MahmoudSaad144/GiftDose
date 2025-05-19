import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyCE8Z_S9GkPrz0_cvEHSF2j_UMIUiJgud8")

    // إعداد نافذة التطبيق يدويًا
    let flutterEngine = (self.window?.rootViewController as? FlutterViewController)?.engine ?? FlutterEngine(name: "my flutter engine")
    flutterEngine.run()
    
    let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = flutterViewController
    self.window?.makeKeyAndVisible()

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
