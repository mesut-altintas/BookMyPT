import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

// PT Screens
import '../../features/pt_members/presentation/screens/pt_dashboard_screen.dart';
import '../../features/pt_members/presentation/screens/member_list_screen.dart';
import '../../features/pt_members/presentation/screens/member_detail_screen.dart';
import '../../features/pt_members/presentation/screens/add_member_screen.dart';
import '../../features/pt_programs/presentation/screens/program_list_screen.dart';
import '../../features/pt_programs/presentation/screens/program_detail_screen.dart';
import '../../features/pt_programs/presentation/screens/create_program_screen.dart';
import '../../shared/models/program_model.dart';
import '../../features/pt_calendar/presentation/screens/pt_calendar_screen.dart';
import '../../features/pt_calendar/presentation/screens/session_detail_screen.dart';
import '../../features/pt_earnings/presentation/screens/earnings_screen.dart';
import '../../features/pt_earnings/presentation/screens/package_management_screen.dart';

// Member Screens
import '../../features/m_booking/presentation/screens/member_dashboard_screen.dart';
import '../../features/m_booking/presentation/screens/booking_screen.dart';
import '../../features/m_booking/presentation/screens/booking_confirm_screen.dart';
import '../../features/m_programs/presentation/screens/member_programs_screen.dart';
import '../../features/m_programs/presentation/screens/workout_detail_screen.dart';
import '../../features/m_progress/presentation/screens/progress_screen.dart';
import '../../features/m_progress/presentation/screens/add_progress_screen.dart';
import '../../features/m_payment/presentation/screens/payment_screen.dart';
import '../../features/m_payment/presentation/screens/payment_history_screen.dart';
import '../../features/m_chat/presentation/screens/chat_list_screen.dart';
import '../../features/m_chat/presentation/screens/chat_screen.dart';
import '../../features/m_calendar/presentation/screens/member_calendar_screen.dart';
import '../../features/m_calendar/presentation/screens/invitation_list_screen.dart';
import '../../features/pt_search/presentation/screens/find_pt_screen.dart';

// Shared
import '../../shared/widgets/pt_shell.dart';
import '../../shared/widgets/member_shell.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const forgotPassword = '/forgot-password';

  // PT
  static const ptDashboard = '/pt/dashboard';
  static const ptMembers = '/pt/members';
  static const memberDetail = '/pt/members/:memberId';
  static const addMember = '/pt/members/add';
  static const ptPrograms = '/pt/programs';
  static const programDetail = '/pt/programs/:programId';
  static const createProgram = '/pt/programs/create';
  static const ptCalendar = '/pt/calendar';
  static const sessionDetail = '/pt/calendar/:sessionId';
  static const ptEarnings = '/pt/earnings';
  static const packageManagement = '/pt/earnings/packages';
  static const ptChatList = '/pt/chat';
  static const ptChat = '/pt/chat/:chatId';

  // Member shell routes
  static const memberDashboard = '/member/dashboard';
  static const memberCalendar = '/member/calendar';
  static const memberPrograms = '/member/programs';
  static const workoutDetail = '/member/programs/:programId';
  static const progress = '/member/progress';
  static const addProgress = '/member/progress/add';
  static const payment = '/member/payment';
  static const paymentHistory = '/member/payment/history';
  static const chatList = '/member/chat';
  static const chat = '/member/chat/:chatId';

  // Member full-screen (outside shell)
  static const booking = '/member/booking';
  static const bookingConfirm = '/member/booking/confirm';
  static const invitations = '/member/invitations';
  static const findPt = '/member/find-pt';

  // Shared
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier();
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.roleSelection ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return RoleSelectionScreen(
              uid: extra['uid'] as String? ?? '',
              name: extra['name'] as String? ?? '',
            );
          }
          return RoleSelectionScreen(uid: extra as String? ?? '', name: '');
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),

      // Member full-screen routes (outside shell — no bottom nav)
      GoRoute(
        path: AppRoutes.booking,
        builder: (_, __) => const BookingScreen(),
        routes: [
          GoRoute(
            path: 'confirm',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BookingConfirmScreen(sessionData: extra ?? {});
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.invitations,
        builder: (_, __) => const InvitationListScreen(),
      ),
      GoRoute(
        path: AppRoutes.findPt,
        builder: (_, __) => const FindPtScreen(),
      ),

      // PT Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => PtShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.ptDashboard,
            builder: (_, __) => const PtDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.ptMembers,
            builder: (_, __) => const MemberListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddMemberScreen(),
              ),
              GoRoute(
                path: ':memberId',
                builder: (_, state) => MemberDetailScreen(
                  memberId: state.pathParameters['memberId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.ptPrograms,
            builder: (_, __) => const ProgramListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateProgramScreen(),
              ),
              GoRoute(
                path: ':programId',
                builder: (_, state) => ProgramDetailScreen(
                  programId: state.pathParameters['programId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => CreateProgramScreen(
                      initialProgram: state.extra as ProgramModel,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.ptCalendar,
            builder: (_, __) => const PtCalendarScreen(),
            routes: [
              GoRoute(
                path: ':sessionId',
                builder: (_, state) => SessionDetailScreen(
                  sessionId: state.pathParameters['sessionId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.ptEarnings,
            builder: (_, __) => const EarningsScreen(),
            routes: [
              GoRoute(
                path: 'packages',
                builder: (_, __) => const PackageManagementScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.ptChatList,
            builder: (_, __) =>
                const ChatListScreen(chatDetailBasePath: '/pt/chat'),
            routes: [
              GoRoute(
                path: ':chatId',
                builder: (_, state) => ChatScreen(
                  chatId: state.pathParameters['chatId']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // Member Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MemberShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.memberDashboard,
            builder: (_, __) => const MemberDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.memberCalendar,
            builder: (_, __) => const MemberCalendarScreen(),
          ),
          GoRoute(
            path: AppRoutes.memberPrograms,
            builder: (_, __) => const MemberProgramsScreen(),
            routes: [
              GoRoute(
                path: ':programId',
                builder: (_, state) => WorkoutDetailScreen(
                  programId: state.pathParameters['programId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (_, __) => const ProgressScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddProgressScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.payment,
            builder: (_, __) => const PaymentScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (_, __) => const PaymentHistoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.chatList,
            builder: (_, __) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':chatId',
                builder: (_, state) => ChatScreen(
                  chatId: state.pathParameters['chatId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Ana Sayfaya Git'),
            ),
          ],
        ),
      ),
    ),
  );
});
