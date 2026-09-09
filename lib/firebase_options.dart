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
    apiKey: 'AIzaSyAH9XONxkgbRLS4_rXfsGeYqDE4ibfYg0Q',
    appId: '1:187713861534:web:a1fb286484f61e6ce3488f',
    messagingSenderId: '187713861534',
    projectId: 'pawcare-app-2026',
    authDomain: 'pawcare-app-2026.firebaseapp.com',
    storageBucket: 'pawcare-app-2026.firebasestorage.app',
    measurementId: 'G-4SSXH7GYGC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAH9XONxkgbRLS4_rXfsGeYqDE4ibfYg0Q',
    appId: '1:187713861534:android:pawcare2026',
    messagingSenderId: '187713861534',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAH9XONxkgbRLS4_rXfsGeYqDE4ibfYg0Q',
    appId: '1:187713861534:ios:pawcare2026',
    messagingSenderId: '187713861534',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.firebasestorage.app',
    iosBundleId: 'com.pawcare.petcare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAH9XONxkgbRLS4_rXfsGeYqDE4ibfYg0Q',
    appId: '1:187713861534:ios:pawcare2026',
    messagingSenderId: '187713861534',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.firebasestorage.app',
    iosBundleId: 'com.pawcare.petcare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAH9XONxkgbRLS4_rXfsGeYqDE4ibfYg0Q',
    appId: '1:187713861534:web:a1fb286484f61e6ce3488f',
    messagingSenderId: '187713861534',
    projectId: 'pawcare-app-2026',
    storageBucket: 'pawcare-app-2026.firebasestorage.app',
  );
}
