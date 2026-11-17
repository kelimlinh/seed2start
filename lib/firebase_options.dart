// Generated from the Firebase configuration already present in this project.
// Firebase client configuration is public application configuration, not a
// server secret. Never place service-account keys or backend secrets here.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase chưa được cấu hình cho nền tảng này.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCur23575E2amyDiJDqHfWvy30I6XkDxqo',
    appId: '1:918737844267:web:ae346b4685346e4923926e',
    messagingSenderId: '918737844267',
    projectId: 'psycapweb',
    storageBucket: 'psycapweb.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCur23575E2amyDiJDqHfWvy30I6XkDxqo',
    appId: '1:918737844267:android:80009f9df9ba311123926e',
    messagingSenderId: '918737844267',
    projectId: 'psycapweb',
    storageBucket: 'psycapweb.firebasestorage.app',
  );
}
