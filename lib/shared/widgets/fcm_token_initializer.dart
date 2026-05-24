import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Invisible widget placed inside PtShell and MemberShell.
/// Saves the FCM token once per session. Retries automatically each time
/// the app comes to the foreground — necessary because TestFlight/cold
/// launches often start in background where APNs is not yet available.
class FcmTokenInitializer extends ConsumerStatefulWidget {
  const FcmTokenInitializer({super.key});

  @override
  ConsumerState<FcmTokenInitializer> createState() =>
      _FcmTokenInitializerState();
}

class _FcmTokenInitializerState extends ConsumerState<FcmTokenInitializer>
    with WidgetsBindingObserver {
  /// Process-level guard — survives widget rebuilds/remounts.
  static bool _saved = false;

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

  /// Retry every time the app comes to the foreground until token is saved.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryInit();
    }
  }

  void _tryInit() {
    if (_saved || _running) return;
    _init();
  }

  Future<void> _init() async {
    _running = true;
    try {
      // Brief pause — lets APNs settle after app becomes active.
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) { _running = false; return; }

      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) { _running = false; return; }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Build 95: skip getAPNSToken() check entirely — call getToken() directly.
      // Firebase SDK handles APNs registration internally; getAPNSToken() was
      // always returning null even when everything else was correct.
      String? diagMsg;
      try {
        final token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 30));

        if (token != null && mounted) {
          final platform = Platform.isIOS ? 'ios' : 'android';
          diagMsg = 'token_ok';
          await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set(
                {'fcmTokens': {platform: token}, '_fcmDiag95': diagMsg},
                SetOptions(merge: true),
              );
          _saved = true;
        } else {
          diagMsg = 'token_null';
          if (mounted) {
            await FirebaseFirestore.instance
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .set({'_fcmDiag95': diagMsg}, SetOptions(merge: true));
          }
        }
      } catch (e) {
        diagMsg = 'exception: $e';
        if (mounted) {
          await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set({'_fcmDiag95': diagMsg}, SetOptions(merge: true));
        }
      }
    } catch (_) {
      // Will retry on next foreground resume.
    }
    _running = false;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
