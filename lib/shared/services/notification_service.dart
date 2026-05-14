import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'bookmypt_default',
    'BookMyPt Bildirimleri',
    description: 'Randevu ve seans bildirimleri',
    importance: Importance.high,
  );

  /// Called when user taps a local notification (app in foreground).
  static void Function(String route)? onLocalNotificationTap;

  /// Called when a foreground FCM message arrives — pass the `type` value.
  static void Function(String type)? onForegroundMessage;

  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();

    // iOS: show notification banner even when app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground: show local notification + fire badge callback
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final route = message.data['route'] as String?;
      final type  = message.data['type']  as String?;

      // On iOS, setForegroundNotificationPresentationOptions already makes
      // the system display the FCM notification natively in the foreground.
      // Showing a local notification here too would cause a duplicate.
      // On Android, FCM never displays notifications in the foreground, so
      // we must show one manually.
      if (notification != null && !Platform.isIOS) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: route, // passed to onDidReceiveNotificationResponse
        );
      }

      if (type != null) {
        onForegroundMessage?.call(type);
      }
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          onLocalNotificationTap?.call(route);
        }
      },
    );

    // Create Android channel
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
