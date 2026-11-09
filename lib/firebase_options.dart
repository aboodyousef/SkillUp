import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

//  Default [FirebaseOptions] for use with your Firebase apps.
// 
//  Example:
//  ```dart
//  import 'firebase_options.dart';
//  // ...
//  await Firebase.initializeApp(
//    options: DefaultFirebaseOptions.currentPlatform,
//  );
// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCg8Juc1fn0iLytx6qmk-U3Gh1yoaD8UdQ',
    appId: '1:77598063379:web:286d1d4d32853f4f49b8e6',
    messagingSenderId: '77598063379',
    projectId: 'skillup-f7226',
    authDomain: 'skillup-f7226.firebaseapp.com',
    storageBucket: 'skillup-f7226.firebasestorage.app',
    measurementId: 'G-VBS56DH8F2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_mU6-pZlCwEPTGcc-GnlHqIg-bfSR_Jw',
    appId: '1:77598063379:android:2dedc10a69ac200849b8e6',
    messagingSenderId: '77598063379',
    projectId: 'skillup-f7226',
    storageBucket: 'skillup-f7226.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUUcFR4BSpHogE8bKTLFDMix0l8P7OOzk',
    appId: '1:77598063379:ios:25a124e60330744449b8e6',
    messagingSenderId: '77598063379',
    projectId: 'skillup-f7226',
    storageBucket: 'skillup-f7226.firebasestorage.app',
    iosBundleId: 'com.skillup.skillUp',
  );
}
