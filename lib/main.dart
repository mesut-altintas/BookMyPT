import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable offline persistence to prevent stale auth error states from
  // carrying over across user sessions (logout → login permission-denied bug).
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  // Fire-and-forget — permission dialog must not block runApp
  NotificationService().initialize().catchError((_) {});

  // Set preferred orientations
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

class FitCoachApp extends ConsumerWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isPt = currentUser.valueOrNull?.isPt ?? false;

    // Setup FCM token refresh listener
    ref.listen(currentUserProvider, (_, userAsync) {
      userAsync.whenData((user) async {
        if (user != null) {
          // Update FCM token
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
      theme: isPt ? AppTheme.ptLightTheme : AppTheme.memberLightTheme,
      darkTheme: isPt ? AppTheme.ptDarkTheme : AppTheme.memberDarkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),
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
