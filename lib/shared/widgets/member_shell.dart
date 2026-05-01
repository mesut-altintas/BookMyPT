import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class MemberShell extends StatelessWidget {
  final Widget child;

  const MemberShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/member/booking')) return 1;
    if (location.startsWith('/member/programs')) return 2;
    if (location.startsWith('/member/progress')) return 3;
    if (location.startsWith('/member/payment')) return 4;
    if (location.startsWith('/member/chat')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.memberDashboard); break;
            case 1: context.go(AppRoutes.booking); break;
            case 2: context.go(AppRoutes.memberPrograms); break;
            case 3: context.go(AppRoutes.progress); break;
            case 4: context.go(AppRoutes.payment); break;
            case 5: context.go(AppRoutes.chatList); break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 20),
            selectedIcon: Icon(Icons.home, size: 20),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, size: 20),
            selectedIcon: Icon(Icons.calendar_month, size: 20),
            label: 'Randevu',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined, size: 20),
            selectedIcon: Icon(Icons.fitness_center, size: 20),
            label: 'Program',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined, size: 20),
            selectedIcon: Icon(Icons.trending_up, size: 20),
            label: 'İlerleme',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, size: 20),
            selectedIcon: Icon(Icons.inventory_2, size: 20),
            label: 'Paketlerim',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined, size: 20),
            selectedIcon: Icon(Icons.chat, size: 20),
            label: 'Mesaj',
          ),
        ],
      ),
    );
  }
}
