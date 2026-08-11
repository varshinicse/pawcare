import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for PawCare app.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_MockApiKey_PawCare_2026',
    appId: '1:123456789:web:pawcare2026',
    messagingSenderId: '123456789',
    projectId: 'pawcare-app-2026',
    authDomain: 'pawcare-app-2026.firebaseapp.com',
    storageBucket: 'pawcare-app-2026.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_MockApiKey_PawCare_Android',
    appId: '1:123456789:android:pawcare2026',
    messagingSenderId: '123456789',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_MockApiKey_PawCare_iOS',
    appId: '1:123456789:ios:pawcare2026',
    messagingSenderId: '123456789',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.appspot.com',
    iosBundleId: 'com.pawcare.petcare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_MockApiKey_PawCare_macOS',
    appId: '1:123456789:ios:pawcare2026',
    messagingSenderId: '123456789',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.appspot.com',
    iosBundleId: 'com.pawcare.petcare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_MockApiKey_PawCare_Windows',
    appId: '1:123456789:web:pawcare2026',
    messagingSenderId: '123456789',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.appspot.com',
  );
}
