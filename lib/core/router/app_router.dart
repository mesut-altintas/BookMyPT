import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/pt_phone_login_screen.dart';
import '../../features/auth/presentation/screens/pt_otp_screen.dart';
import '../../features/auth/presentation/screens/pt_register_screen.dart';
import '../../features/auth/presentation/screens/member_login_screen.dart';
import '../../features/pt/presentation/screens/pt_home_screen.dart';
import '../../features/member/presentation/screens/member_home_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String ptLogin = '/pt/login';
  static const String ptOtp = '/pt/otp';
  static const String ptRegister = '/pt/register';
  static const String memberLogin = '/member/login';
  static const String ptHome = '/pt/home';
  static const String memberHome = '/member/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation.startsWith('/pt/login') ||
          state.matchedLocation.startsWith('/pt/otp') ||
          state.matchedLocation.startsWith('/pt/register') ||
          state.matchedLocation.startsWith('/member/login');

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.welcome;
      }

      if (isLoggedIn && state.matchedLocation == AppRoutes.welcome) {
        return user.role == UserRole.pt ? AppRoutes.ptHome : AppRoutes.memberHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.ptLogin,
        builder: (_, __) => const PtPhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.ptOtp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return PtOtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.ptRegister,
        builder: (_, __) => const PtRegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.memberLogin,
        builder: (_, __) => const MemberLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.ptHome,
        builder: (_, __) => const PtHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.memberHome,
        builder: (_, __) => const MemberHomeScreen(),
      ),
    ],
  );
});
