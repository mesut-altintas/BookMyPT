import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Invisible widget placed inside PtShell and MemberShell.
///
/// Token strategy:
/// - Tracks the last UID that saved a token via SharedPreferences.
/// - On login with a different UID, removes the token from the previous
///   user's Firestore doc so they no longer receive notifications on this
///   device, then saves the current user's token.
/// - Token is NOT deleted on logout — last logged-in user keeps receiving
///   notifications until someone else logs in on this device.
/// - Uses UID-based static guard so switching accounts always triggers a
///   fresh save without needing a full app restart.
class FcmTokenInitializer extends ConsumerStatefulWidget {
  const FcmTokenInitializer({super.key});

  @override
  ConsumerState<FcmTokenInitializer> createState() =>
      _FcmTokenInitializerState();
}

class _FcmTokenInitializerState extends ConsumerState<FcmTokenInitializer>
    with WidgetsBindingObserver {
  /// UID of the user whose token was last successfully saved this process.
  /// Null means no save has happened yet.
  static String? _savedUid;

  /// Prevents concurrent _init() calls.
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tryInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Retry every time the app comes to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tryInit();
  }

  void _tryInit() {
    if (_running) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    // Already saved for this user — skip.
    if (user != null && _savedUid == user.uid) return;
    _init();
  }

  Future<void> _init() async {
    _running = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) { _running = false; return; }

      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) { _running = false; return; }

      // Already saved for this user — skip.
      if (_savedUid == user.uid) { _running = false; return; }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Read native APNs diagnostic (iOS only).
      String nativeDiag = 'not_ios';
      if (Platform.isIOS) {
        try {
          const channel = MethodChannel('com.bookmypt/native_diag');
          nativeDiag = await channel.invokeMethod<String>('getApnsDiag')
              ?? 'channel_null';
        } catch (e) {
          nativeDiag = 'channel_err:$e';
        }
      }

      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 30));

      if (token == null || !mounted) { _running = false; return; }

      final platform = Platform.isIOS ? 'ios' : 'android';
      final prefs = await SharedPreferences.getInstance();
      final previousUid = prefs.getString('fcm_last_uid');

      // Remove token from previous user's doc if they're a different person.
      if (previousUid != null && previousUid != user.uid) {
        try {
          await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(previousUid)
              .update({'fcmTokens.$platform': FieldValue.delete()});
        } catch (_) {
          // Previous user doc may not exist — ignore.
        }
      }

      // Save token for current user.
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(
            {
              'fcmTokens': {platform: token},
              '_fcmDiag': 'token_ok',
              '_apnsDiag': nativeDiag,
            },
            SetOptions(merge: true),
          );

      await prefs.setString('fcm_last_uid', user.uid);
      _savedUid = user.uid;
    } catch (_) {
      // Will retry on next foreground resume.
    }
    _running = false;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
