// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCfpohEQus7A8foNN7Hxizwqds1i-uMPQ8',
    appId: '1:774792223206:web:3a2452e97216695f001e27',
    messagingSenderId: '774792223206',
    projectId: 'aparna-education-ab56c',
    authDomain: 'aparna-education-ab56c.firebaseapp.com',
    storageBucket: 'aparna-education-ab56c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8vmzrOXR0fmWKJ_KZSyRDVRSELAZa3vo',
    appId: '1:774792223206:android:54c3a43b1f9fab6d001e27',
    messagingSenderId: '774792223206',
    projectId: 'aparna-education-ab56c',
    storageBucket: 'aparna-education-ab56c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAznCzvseRHIZOPDq3NyHjMQNIMw_0U9Y',
    appId: '1:774792223206:ios:9e372aae65597bdb001e27',
    messagingSenderId: '774792223206',
    projectId: 'aparna-education-ab56c',
    storageBucket: 'aparna-education-ab56c.appspot.com',
    iosBundleId: 'com.example.aparnaEducation',
  );
}
