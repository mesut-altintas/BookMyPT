import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/extensions.dart';
import '../../core/router/app_router.dart';
import '../../shared/services/notification_badge_service.dart';
import 'fcm_token_initializer.dart';

class PtShell extends ConsumerWidget {
  final Widget child;

  const PtShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/pt/members')) return 1;
    if (location.startsWith('/pt/calendar')) return 2;
    if (location.startsWith('/pt/earnings')) return 3;
    if (location.startsWith('/pt/chat')) return 4;
    return 0;
  }

  Widget _badgedIcon(Widget icon, int count) {
    if (count == 0) return icon;
    return badges.Badge(
      badgeContent: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 9),
      ),
      badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);
    final badgeMap = ref.watch(notificationBadgeProvider);
    final l10n = context.l10n;

    void go(int index, String route, [NotificationSource? source]) {
      if (source != null) {
        ref.read(notificationBadgeProvider.notifier).clear(source);
      }
      context.go(route);
    }

    return Scaffold(
      body: Stack(
        children: [
          child,
          const FcmTokenInitializer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: go(0, AppRoutes.ptDashboard); break;
            case 1: go(1, AppRoutes.ptMembers, NotificationSource.members); break;
            case 2: go(2, AppRoutes.ptCalendar, NotificationSource.calendar); break;
            case 3: go(3, AppRoutes.ptEarnings, NotificationSource.earnings); break;
            case 4: go(4, AppRoutes.ptChatList, NotificationSource.chat); break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, size: 20),
            selectedIcon: const Icon(Icons.home, size: 20),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: _badgedIcon(const Icon(Icons.people_outline, size: 20),
                badgeMap[NotificationSource.members] ?? 0),
            selectedIcon: const Icon(Icons.people, size: 20),
            label: l10n.navMembers,
          ),
          NavigationDestination(
            icon: _badgedIcon(const Icon(Icons.calendar_today_outlined, size: 20),
                badgeMap[NotificationSource.calendar] ?? 0),
            selectedIcon: const Icon(Icons.calendar_today, size: 20),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: _badgedIcon(const Icon(Icons.account_balance_wallet_outlined, size: 20),
                badgeMap[NotificationSource.earnings] ?? 0),
            selectedIcon: const Icon(Icons.account_balance_wallet, size: 20),
            label: l10n.navEarnings,
          ),
          NavigationDestination(
            icon: _badgedIcon(const Icon(Icons.chat_outlined, size: 20),
                badgeMap[NotificationSource.chat] ?? 0),
            selectedIcon: const Icon(Icons.chat, size: 20),
            label: l10n.navChat,
          ),
        ],
      ),
    );
  }
}
