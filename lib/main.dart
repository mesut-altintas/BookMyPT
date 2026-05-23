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

class _FitCoachAppState extends ConsumerState<FitCoachApp>
    with WidgetsBindingObserver {
  // ── FCM state ──────────────────────────────────────────────────────────────
  final String _platform = Platform.isIOS ? 'ios' : 'android';

  /// True once token has been successfully written to Firestore.
  /// Prevents re-entry: writing to the user doc triggers currentUserProvider
  /// to re-emit, which would restart _saveFcmToken in an infinite loop.
  bool _fcmTokenSaved = false;

  ProviderSubscription<AsyncValue<UserModel?>>? _userSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotifications();
    // listenManual + fireImmediately covers both "user already loaded" and
    // "user loads later" cases — ref.listen in build() misses the former.
    _userSub = ref.listenManual(
      currentUserProvider,
      (_, next) {
        next.whenData((user) {
          if (user != null) {
            _saveFcmToken(user.uid);
          } else {
            _fcmTokenSaved = false; // logged out → reset for next login
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userSub?.close();
    super.dispose();
  }

  /// Retry FCM token save every time the app comes to foreground.
  /// getToken() requires foreground on iOS — background calls hang/fail.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_fcmTokenSaved) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) _saveFcmToken(user.uid);
    }
  }

  // ── FCM token ──────────────────────────────────────────────────────────────

  /// Saves the FCM token for this device to Firestore once per session.
  /// Uses a guard flag so Firestore writes never trigger a second call.
  Future<void> _saveFcmToken(String uid) async {
    if (_fcmTokenSaved) return;
    _fcmTokenSaved = true; // set before any await — blocks re-entry immediately

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 10 s timeout. On iOS the call hangs when the app is in background
      // because APNs registration requires foreground context.
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 10));

      if (token != null) {
        await _writeToken(uid, token);
        return; // success — _fcmTokenSaved stays true
      }
    } catch (_) {
      // Timeout or other error — fall through to retry logic below
    }

    // Getting here means we failed (background timeout is the common case).
    _fcmTokenSaved = false;

    // If the app is already in the foreground now (e.g. the 10 s background
    // timeout just fired while the user is actively using the app), retry
    // immediately instead of waiting for the next lifecycle event.
    if (mounted &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 500));
      _saveFcmToken(uid);
    }
  }

  Future<void> _writeToken(String uid, String token) =>
      FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set({'fcmTokens': {_platform: token}}, SetOptions(merge: true));

  // ── Notifications setup ───────────────────────────────────────────────────

  void _setupNotifications() {
    // Local notification tap (foreground)
    NotificationService.onLocalNotificationTap = (route) {
      navigatorKey.currentContext?.go(route);
    };

    // Foreground FCM → increment badge counter
    NotificationService.onForegroundMessage = (type) {
      final source = notificationSourceFromType(type);
      if (source != null) {
        ref.read(notificationBadgeProvider.notifier).increment(source);
      }
    };

    // Background tap (app was suspended)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'] as String?;
      if (route != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey.currentContext?.go(route);
        });
      }
    });

    // Token refresh (iOS re-issues APNs token after reinstall / new build)
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      _fcmTokenSaved = false; // allow overwrite with fresh token
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        _fcmTokenSaved = true;
        await _writeToken(user.uid, token);
      }
      // If user not loaded yet, _saveFcmToken will call getToken() which
      // returns the cached token once APNs registration completes.
    });

    // Terminated tap (app was fully closed)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final route = message.data['route'] as String?;
        if (route != null) _navigateWhenReady(route);
      }
    });
  }

  /// Retries navigation every 200 ms until the router context is ready.
  void _navigateWhenReady(String route, {int attempt = 0}) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ctx.go(route);
    } else if (attempt < 25) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _navigateWhenReady(route, attempt: attempt + 1);
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
