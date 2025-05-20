// main.dart

// عشان تتأكد إن مفيش بلاجن ولا صلاحيات بتتضايق:
// أعمل كومنت لكل الـ imports اللي برا Flutter الأساسية
// import 'package:giftdose/auth/forget%20password.dart';
// import 'package:giftdose/auth/longin.dart';
// import 'package:giftdose/auth/singup.dart';
// import 'package:giftdose/navpar/darwar/occasions/add_occasions.dart';
// import 'package:giftdose/navpar/darwar/occasions/occasions.dart';
// import 'package:giftdose/navpar/darwar/profile/profile.dart';
// import 'package:giftdose/navpar/darwar/settings.dart';
// import 'package:giftdose/navpar/friends/userandfrinds.dart';
// import 'package:giftdose/navpar/navbarpage.dart';
// import 'package:giftdose/no_internet.dart';
// import 'package:giftdose/startpage.dart';
// import 'package:giftdose/translation/language_service.dart';
// import 'package:giftdose/translation/translation_service.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:get/get.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تجربة بسيطة',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تجربة Codemagic'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // لمن تعمل زرار بسيط:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('التطبيق شغال بدون بلاجين!')),
            );
          },
          child: const Text('اضغط هنا'),
        ),
      ),
    );
  }
}
