import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:giftdose/auth/forget%20password.dart';
import 'package:giftdose/auth/longin.dart';
import 'package:giftdose/auth/singup.dart';
import 'package:giftdose/navpar/darwar/occasions/add_occasions.dart';
import 'package:giftdose/navpar/darwar/occasions/occasions.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/navpar/darwar/settings.dart';
import 'package:giftdose/navpar/friends/userandfrinds.dart';
import 'package:giftdose/navpar/navbarpage.dart';
import 'package:giftdose/no_internet.dart';
import 'package:giftdose/startpage.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:giftdose/translation/translation_service.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool hasInternet = await checkInternetConnection();
  Get.put(ProfileController());
  await setupNotifications();

  Locale savedLocale = await LanguageService.getSavedLanguage();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp(
      savedLocale: savedLocale,
      hasInternet: hasInternet,
    ));
  });
}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class MyApp extends StatefulWidget {
  final Locale savedLocale;
  final bool hasInternet;
  const MyApp(
      {super.key, required this.savedLocale, required this.hasInternet});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale;
    myrequestpermission();
  }

  void changeLocale(Locale locale) async {
    await LanguageService.changeLanguage(locale);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: TranslationService(),
      locale: _locale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: widget.hasInternet ? "/" : "/no-internet",
      getPages: [
        GetPage(name: "/", page: () => StartPage()),
        GetPage(name: "/no-internet", page: () => NoInternetPage()),
        GetPage(name: "/1", page: () => Longinpage()),
        GetPage(name: "/2", page: () => Singuppage()),
        GetPage(name: "/3", page: () => Forgetpasswordpage()),
        GetPage(name: "/4", page: () => Navbarpage()),
        GetPage(name: "/5", page: () => ProfilePage()),
        GetPage(name: "/6", page: () => AddOccasions()),
        GetPage(name: "/7", page: () => Occasions()),
        GetPage(name: "/8", page: () => SettingsPage()),
        GetPage(name: "/10", page: () => UserAndFriendsPage()),
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

Future<void> setupNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@drawable/ic_stat_ic_notification');

  // ✅ التعديل هنا باستخدام الكلاس الصحيح
  const DarwinInitializationSettings iosInitializationSettings =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );

  // 1) مسح كل الإشعارات
  await flutterLocalNotificationsPlugin.cancelAll();

  // 2) تصفير البادج على iOS
  try {
    await const MethodChannel('app.badge').invokeMethod('clearBadge');
  } catch (e) {
    // لو Android مش هتشتغل القناة دي، متقلقش
    print('Failed to clear badge: $e');
  }

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      Get.find<ProfileController>().getData();
    }
  });
}

myrequestpermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب إذن الإشعارات
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional notification permission');
  } else {
    print('User declined or has not accepted notification permission');
  }

  // طلب إذن الكاميرا
  PermissionStatus cameraStatus = await Permission.camera.request();
  if (cameraStatus.isGranted) {
    print("Camera permission granted");
  } else {
    print("Camera permission denied");
  }

  // تحديث الحالة في صفحة الإعدادات بعد طلب الأذونات
  updatePermissionStatus(cameraStatus, settings);
}

void updatePermissionStatus(
    PermissionStatus cameraStatus, NotificationSettings settings) {}
