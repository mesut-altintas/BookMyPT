import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:io';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/notification_badge_service.dart';
import 'shared/services/theme_service.dart';
import 'shared/services/locale_service.dart';
import 'shared/services/color_scheme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable offline persistence to prevent stale auth error states
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  // Fire-and-forget — permission dialog must not block runApp
  NotificationService().initialize().catchError((_) {});

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: FitCoachApp(),
    ),
  );
}

class FitCoachApp extends ConsumerStatefulWidget {
  const FitCoachApp({super.key});

  @override
  ConsumerState<FitCoachApp> createState() => _FitCoachAppState();
}

class _FitCoachAppState extends ConsumerState<FitCoachApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  /// Retries navigation every 200 ms until the router context is ready.
  /// Needed when the app starts from a terminated state via a notification tap.
  void _navigateWhenReady(String route, {int attempt = 0}) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ctx.go(route);
    } else if (attempt < 25) {
      // Try for up to 5 seconds (25 × 200 ms)
      Future.delayed(const Duration(milliseconds: 200), () {
        _navigateWhenReady(route, attempt: attempt + 1);
      });
    }
  }

  String _fcmPlatform = 'android';

  /// Tries to obtain the FCM token and write it to Firestore.
  /// - On iOS: waits up to 30 s for the APNs token before calling getToken().
  /// - Retries getToken() up to 5 times (with growing delays) in case of
  ///   transient network issues.
  /// - If all attempts fail, deletes the stale token so the SDK requests a
  ///   fresh one; that triggers onTokenRefresh which saves it automatically.
  Future<void> _saveFcmToken(String uid, String platform) async {
    try {
      if (Platform.isIOS) {
        String? apns;
        for (var i = 0; i < 30 && apns == null; i++) {
          apns = await FirebaseMessaging.instance.getAPNSToken();
          if (apns == null) await Future.delayed(const Duration(seconds: 1));
        }
        if (apns == null) return; // APNs unavailable — onTokenRefresh will retry
      }

      String? token;
      for (var attempt = 0; attempt < 5 && token == null; attempt++) {
        if (attempt > 0) {
          await Future.delayed(Duration(seconds: attempt * 3));
        }
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token != null) {
        await ref.read(authRepositoryProvider).updateFcmToken(uid, token, platform);
      } else {
        // Force the SDK to request a new token; onTokenRefresh will pick it up.
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (_) {
      // Silent — onTokenRefresh acts as fallback
    }
  }

  void _setupNotifications() {
    // ── Local notification tap (app in foreground) ──────────────────────────
    NotificationService.onLocalNotificationTap = (route) {
      navigatorKey.currentContext?.go(route);
    };

    // ── Foreground FCM message → increment badge ────────────────────────────
    NotificationService.onForegroundMessage = (type) {
      final source = notificationSourceFromType(type);
      if (source != null) {
        ref.read(notificationBadgeProvider.notifier).increment(source);
      }
    };

    // ── Background tap: app was in background, user tapped notification ─────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'] as String?;
      if (route != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey.currentContext?.go(route);
        });
      }
    });

    // ── FCM token: saved in build() via ref.listen (same pattern as the
    //    original working implementation). The platform key is captured once.
    _fcmPlatform = Platform.isIOS ? 'ios' : 'android';

    // ── FCM token refresh → save new token to Firestore immediately ────────
    // iOS reassigns the APNs token after new builds / reinstalls.
    // Without this listener the old token stays in Firestore and
    // push notifications silently stop arriving.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        await ref.read(authRepositoryProvider).updateFcmToken(user.uid, newToken, _fcmPlatform);
      }
    });

    // ── Terminated tap: app was closed, user tapped notification ───────────
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final route = message.data['route'] as String?;
        if (route != null) {
          _navigateWhenReady(route);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isPt = currentUser.valueOrNull?.isPt ?? false;

    // Save FCM token whenever the user object appears / changes.
    // Placed in build() so it runs on every provider emission — the same
    // reliable pattern as the original working implementation.
    ref.listen(currentUserProvider, (_, userAsync) {
      userAsync.whenData((user) async {
        if (user != null) {
          _saveFcmToken(user.uid, _fcmPlatform);
        }
      });
    });


    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: colorScheme == AppColorScheme.sport
          ? AppTheme.sportLightTheme
          : (isPt ? AppTheme.ptLightTheme : AppTheme.memberLightTheme),
      darkTheme: colorScheme == AppColorScheme.sport
          ? AppTheme.sportDarkTheme
          : (isPt ? AppTheme.ptDarkTheme : AppTheme.memberDarkTheme),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: locale,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
