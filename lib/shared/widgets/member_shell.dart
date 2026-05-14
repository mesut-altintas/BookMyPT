import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/extensions.dart';
import '../../core/router/app_router.dart';
import '../../features/m_calendar/providers/invitation_provider.dart';
import '../../shared/services/notification_badge_service.dart';

class MemberShell extends ConsumerWidget {
  final Widget child;

  const MemberShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/member/calendar')) return 1;
    if (location.startsWith('/member/programs')) return 2;
    if (location.startsWith('/member/progress')) return 3;
    if (location.startsWith('/member/payment')) return 4;
    if (location.startsWith('/member/chat')) return 5;
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
    final pendingCount = ref.watch(pendingInvitationsCountProvider);
    final badgeMap = ref.watch(notificationBadgeProvider);
    final l10n = context.l10n;

    void go(String route, [NotificationSource? source]) {
      if (source != null) {
        ref.read(notificationBadgeProvider.notifier).clear(source);
      }
      context.go(route);
    }

    // Home badge = invitations (existing) OR calendar notifications
    final homeBadge = pendingCount + (badgeMap[NotificationSource.calendar] ?? 0);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(size: 18),
          ),
          height: 60,
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            switch (index) {
              case 0: go(AppRoutes.memberDashboard); break;
              case 1: go(AppRoutes.memberCalendar, NotificationSource.calendar); break;
              case 2: go(AppRoutes.memberPrograms); break;
              case 3: go(AppRoutes.progress); break;
              case 4: go(AppRoutes.payment, NotificationSource.payment); break;
              case 5: go(AppRoutes.chatList, NotificationSource.chat); break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: _badgedIcon(const Icon(Icons.home_outlined), homeBadge),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.fitness_center_outlined),
              selectedIcon: const Icon(Icons.fitness_center),
              label: l10n.navPrograms,
            ),
            NavigationDestination(
              icon: const Icon(Icons.trending_up_outlined),
              selectedIcon: const Icon(Icons.trending_up),
              label: l10n.navProgress,
            ),
            NavigationDestination(
              icon: _badgedIcon(const Icon(Icons.inventory_2_outlined),
                  badgeMap[NotificationSource.payment] ?? 0),
              selectedIcon: const Icon(Icons.inventory_2),
              label: l10n.navPackages,
            ),
            NavigationDestination(
              icon: _badgedIcon(const Icon(Icons.chat_outlined),
                  badgeMap[NotificationSource.chat] ?? 0),
              selectedIcon: const Icon(Icons.chat),
              label: l10n.navChat,
            ),
          ],
        ),
      ),
    );
  }
}
