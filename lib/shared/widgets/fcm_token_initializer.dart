import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Invisible widget placed inside PtShell and MemberShell.
/// By the time these shells render, the user is authenticated and the app
/// is definitely in the foreground — the ideal moment to fetch the FCM token.
/// A short initial delay lets APNs complete its registration after a fresh install.
class FcmTokenInitializer extends ConsumerStatefulWidget {
  const FcmTokenInitializer({super.key});

  @override
  ConsumerState<FcmTokenInitializer> createState() =>
      _FcmTokenInitializerState();
}

class _FcmTokenInitializerState extends ConsumerState<FcmTokenInitializer> {
  static bool _saved = false; // process-level guard — survives widget rebuilds

  @override
  void initState() {
    super.initState();
    if (!_saved) _init();
  }

  Future<void> _init() async {
    // Brief delay so APNs registration can complete after a fresh install.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // On iOS, wait for the APNs token — retry every 3 s, up to 5 attempts.
      if (Platform.isIOS) {
        String? apns;
        for (int i = 0; i < 5 && apns == null; i++) {
          if (i > 0) await Future.delayed(const Duration(seconds: 3));
          try {
            apns = await FirebaseMessaging.instance
                .getAPNSToken()
                .timeout(const Duration(seconds: 5));
          } catch (_) {}
        }
        if (apns == null) return; // APNs still not ready — onTokenRefresh will handle it
      }

      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 15));

      if (token != null) {
        final platform = Platform.isIOS ? 'ios' : 'android';
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set({'fcmTokens': {platform: token}}, SetOptions(merge: true));
        _saved = true;
      }
    } catch (_) {
      // Will be retried on next app launch via onTokenRefresh
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
