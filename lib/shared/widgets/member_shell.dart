import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../../core/router/app_router.dart';
import '../../features/m_calendar/providers/invitation_provider.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);
    final pendingCount = ref.watch(pendingInvitationsCountProvider);

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
            case 0:
              context.go(AppRoutes.memberDashboard);
              break;
            case 1:
              context.go(AppRoutes.memberCalendar);
              break;
            case 2:
              context.go(AppRoutes.memberPrograms);
              break;
            case 3:
              context.go(AppRoutes.progress);
              break;
            case 4:
              context.go(AppRoutes.payment);
              break;
            case 5:
              context.go(AppRoutes.chatList);
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: pendingCount > 0
                ? badges.Badge(
                    badgeContent: Text(
                      '$pendingCount',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.home_outlined),
                  )
                : const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Takvim',
          ),
          const NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Program',
          ),
          const NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'İlerleme',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Paketler',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Mesaj',
          ),
        ],
      ),
      ),
    );
  }
}
