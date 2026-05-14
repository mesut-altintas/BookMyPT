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

    // ── Terminated tap: app was closed, user tapped notification ───────────
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final route = message.data['route'] as String?;
        if (route != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            navigatorKey.currentContext?.go(route);
          });
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

    // Setup FCM token refresh listener
    ref.listen(currentUserProvider, (_, userAsync) {
      userAsync.whenData((user) async {
        if (user != null) {
          final token = await NotificationService().getToken();
          if (token != null) {
            await ref
                .read(authRepositoryProvider)
                .updateFcmToken(user.uid, token);
          }
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
