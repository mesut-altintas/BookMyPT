import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../calendar/presentation/screens/pt_calendar_screen.dart';
import '../../members/presentation/screens/pt_members_screen.dart';
import '../../cancellations/presentation/screens/pt_cancellations_screen.dart';
import '../../reports/presentation/screens/pt_reports_screen.dart';
import '../../settings/presentation/screens/pt_settings_screen.dart';

class PtHomeScreen extends ConsumerStatefulWidget {
  const PtHomeScreen({super.key});

  @override
  ConsumerState<PtHomeScreen> createState() => _PtHomeScreenState();
}

class _PtHomeScreenState extends ConsumerState<PtHomeScreen> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Takvim',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: 'Üyeler',
    ),
    NavigationDestination(
      icon: Icon(Icons.cancel_outlined),
      selectedIcon: Icon(Icons.cancel),
      label: 'İptal',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Raporlar',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Ayarlar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex].label),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(user?.name ?? '', style: const TextStyle(fontSize: 14)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final router = GoRouter.of(context);
              ref.read(authNotifierProvider.notifier).signOut().then((_) {
                if (mounted) router.go(AppRoutes.welcome);
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PtCalendarScreen(),
          PtMembersScreen(),
          PtCancellationsScreen(),
          PtReportsScreen(),
          PtSettingsScreen(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations,
      ),
    );
  }
}

