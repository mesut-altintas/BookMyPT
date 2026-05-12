import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/extensions.dart';
import '../../core/router/app_router.dart';

class PtShell extends StatelessWidget {
  final Widget child;

  const PtShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/pt/members')) return 1;
    if (location.startsWith('/pt/programs')) return 2;
    if (location.startsWith('/pt/calendar')) return 3;
    if (location.startsWith('/pt/earnings')) return 4;
    if (location.startsWith('/pt/chat')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final l10n = context.l10n;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.ptDashboard); break;
            case 1: context.go(AppRoutes.ptMembers); break;
            case 2: context.go(AppRoutes.ptPrograms); break;
            case 3: context.go(AppRoutes.ptCalendar); break;
            case 4: context.go(AppRoutes.ptEarnings); break;
            case 5: context.go(AppRoutes.ptChatList); break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined, size: 20),
            selectedIcon: const Icon(Icons.dashboard, size: 20),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline, size: 20),
            selectedIcon: const Icon(Icons.people, size: 20),
            label: l10n.navMembers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined, size: 20),
            selectedIcon: const Icon(Icons.fitness_center, size: 20),
            label: l10n.navPrograms,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            selectedIcon: const Icon(Icons.calendar_today, size: 20),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
            selectedIcon: const Icon(Icons.account_balance_wallet, size: 20),
            label: l10n.navEarnings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined, size: 20),
            selectedIcon: const Icon(Icons.chat, size: 20),
            label: l10n.navChat,
          ),
        ],
      ),
    );
  }
}
