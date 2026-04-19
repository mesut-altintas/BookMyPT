import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web desteklenmiyor.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Bu platform desteklenmiyor: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYP-ky2G1jF6zYBAsgSffgBsKl4z4ikEY',
    appId: '1:288626980549:android:496d6fee77073d9f65a2ac',
    messagingSenderId: '288626980549',
    projectId: 'bookmypt',
    storageBucket: 'bookmypt.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeNHR50Zt4qmOc43k3goOokSZEPJEvH5c',
    appId: '1:288626980549:ios:3facb3eb8457da0865a2ac',
    messagingSenderId: '288626980549',
    projectId: 'bookmypt',
    storageBucket: 'bookmypt.firebasestorage.app',
    iosBundleId: 'com.bookmypt',
  );
}
