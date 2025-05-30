import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8OpmU4G7-tpGjeeAm2euNcIA0mkMHE9g',
    appId: '1:883279588390:android:47610f816780da43210ae7',
    messagingSenderId: '883279588390',
    projectId: 'giftdose-8d4ba',
    storageBucket: 'giftdose-8d4ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACW4_Y5FwpGI_7lMY2mpNFEs1FDtrTPtE',
    appId: '1:883279588390:ios:65aad412c6f194dc210ae7',
    messagingSenderId: '883279588390',
    projectId: 'giftdose-8d4ba',
    storageBucket: 'giftdose-8d4ba.firebasestorage.app',
    iosBundleId: 'com.solinz.giftdose',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAvciFN--rJRtlgAC-9ADevcEKyvUMm4uE',
    appId: '1:883279588390:web:f9665ae71d072641210ae7',
    messagingSenderId: '883279588390',
    projectId: 'giftdose-8d4ba',
    authDomain: 'giftdose-8d4ba.firebaseapp.com',
    storageBucket: 'giftdose-8d4ba.firebasestorage.app',
    measurementId: 'G-99593MSRHR',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACW4_Y5FwpGI_7lMY2mpNFEs1FDtrTPtE',
    appId: '1:883279588390:ios:65aad412c6f194dc210ae7',
    messagingSenderId: '883279588390',
    projectId: 'giftdose-8d4ba',
    storageBucket: 'giftdose-8d4ba.firebasestorage.app',
    iosBundleId: 'com.solinz.giftdose',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvciFN--rJRtlgAC-9ADevcEKyvUMm4uE',
    appId: '1:883279588390:web:cfd59ef5dadf5799210ae7',
    messagingSenderId: '883279588390',
    projectId: 'giftdose-8d4ba',
    authDomain: 'giftdose-8d4ba.firebaseapp.com',
    storageBucket: 'giftdose-8d4ba.firebasestorage.app',
    measurementId: 'G-ENGYDGRY5J',
  );

}