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
import 'shared/models/user_model.dart';
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
  ProviderSubscription<AsyncValue<UserModel?>>? _userSub;

  @override
  void initState() {
    super.initState();
    // Resolve platform before _setupNotifications so onTokenRefresh can use it
    _fcmPlatform = Platform.isIOS ? 'ios' : 'android';
    _setupNotifications();
    // fireImmediately:true ensures we fire even when the provider already has
    // a value when initState runs — ref.listen in build() misses that case.
    _userSub = ref.listenManual(
      currentUserProvider,
      (_, userAsync) {
        userAsync.whenData((user) {
          if (user != null) {
            _saveFcmToken(user.uid, _fcmPlatform);
          } else {
            // User logged out — allow fresh token save on next login
            _fcmTokenSaved = false;
            _savingFcmToken = false;
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _userSub?.close();
    super.dispose();
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

  /// Holds a token that arrived via onTokenRefresh before the user was loaded.
  /// _saveFcmToken picks this up as a fallback so the token isn't lost.
  String? _pendingFcmToken;

  /// Guards against re-entrant / concurrent calls to _saveFcmToken.
  /// Writing to the user document triggers currentUserProvider to re-emit,
  /// which re-triggers listenManual, which would restart _saveFcmToken in an
  /// infinite loop without this flag.
  bool _savingFcmToken = false;
  bool _fcmTokenSaved = false;

  /// Requests notification permission then fetches and saves the FCM token.
  /// On iOS the APNs → Firebase round-trip can take several seconds after
  /// app launch, so getToken() may return null on the first call.
  /// We retry up to 10 times with linear back-off (1 s, 2 s, … 9 s = ~45 s
  /// total) before giving up. onTokenRefresh covers any remaining cases.
  Future<void> _saveFcmToken(String uid, String platform) async {
    if (_fcmTokenSaved || _savingFcmToken) return;
    _savingFcmToken = true;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      // Write permission status to Firestore so we can diagnose remotely
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'_fcmDiag': 'perm:${settings.authorizationStatus.name} plat:$platform'}, SetOptions(merge: true));

      // getToken() can hang indefinitely on iOS if APNs hasn't responded yet.
      // Add a per-attempt timeout so the loop can actually progress.
      String? token;
      String? lastError;
      for (int i = 0; i < 10 && token == null; i++) {
        if (i > 0) await Future.delayed(Duration(seconds: i));
        try {
          token = await FirebaseMessaging.instance
              .getToken()
              .timeout(const Duration(seconds: 8));
        } catch (e) {
          lastError = e.toString();
        }
      }

      // Fallback 1: onTokenRefresh fired before the user was ready
      token ??= _pendingFcmToken;

      // Fallback 2: getToken() kept timing out — wait on onTokenRefresh stream
      // directly. APNs sometimes delivers the token asynchronously via this
      // stream even when getToken() hangs.
      if (token == null) {
        try {
          token = await FirebaseMessaging.instance.onTokenRefresh
              .first
              .timeout(const Duration(seconds: 30));
        } catch (e) {
          lastError = 'onTokenRefresh timeout: $e';
        }
      }

      if (token != null) {
        _pendingFcmToken = null;
        _fcmTokenSaved = true;
        await ref.read(authRepositoryProvider).updateFcmToken(uid, token, platform);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'_fcmDiag': 'ok:${token.substring(0, 10)}'}, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'_fcmDiag': 'failed. err:${lastError ?? "none"}'}, SetOptions(merge: true));
      }
    } catch (e) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'_fcmDiag': 'exception:$e'}, SetOptions(merge: true));
      } catch (_) {}
    } finally {
      _savingFcmToken = false;
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

    // ── FCM token refresh → save new token to Firestore immediately ────────
    // iOS reassigns the APNs token after new builds / reinstalls.
    // Without this listener the old token stays in Firestore and
    // push notifications silently stop arriving.
    // If the user isn't loaded yet (race at startup), stash the token so
    // _saveFcmToken can pick it up once the user provider emits.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        _pendingFcmToken = null;
        await ref.read(authRepositoryProvider).updateFcmToken(user.uid, newToken, _fcmPlatform);
      } else {
        _pendingFcmToken = newToken;
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
