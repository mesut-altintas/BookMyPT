import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../features/m_progress/providers/progress_provider.dart';
import '../../../../shared/models/progress_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/status_badge.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _MemberDashboardContent(
          memberId: user.uid,
          memberName: user.name,
          photoUrl: user.photoUrl,
        );
      },
    );
  }
}

class _MemberDashboardContent extends ConsumerWidget {
  final String memberId;
  final String memberName;
  final String? photoUrl;

  const _MemberDashboardContent({
    required this.memberId,
    required this.memberName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(memberUpcomingSessionsProvider(memberId));
    final progressAsync = ref.watch(latestProgressProvider(memberId));
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberUpcomingSessionsProvider(memberId));
          ref.invalidate(latestProgressProvider(memberId));
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 130,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Merhaba, ${memberName.split(' ').first}!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              DateTime.now().formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push(AppRoutes.profile),
                        child: UserAvatar(
                          photoUrl: photoUrl,
                          name: memberName,
                          radius: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Actions
                  _QuickActions(memberId: memberId),
                  const SizedBox(height: 24),

                  // Upcoming Sessions
                  _SectionHeader(
                    title: 'Yaklaşan Randevular',
                    onSeeAll: () => context.go(AppRoutes.booking),
                  ),
                  const SizedBox(height: 12),
                  sessionsAsync.when(
                    loading: () => const AppLoading(size: 32),
                    error: (e, _) => Text('Hata: $e'),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.calendar_today_outlined,
                          message: 'Yaklaşan randevu yok',
                          actionLabel: 'Randevu Al',
                          onAction: () => context.go(AppRoutes.booking),
                        );
                      }
                      return Column(
                        children: sessions
                            .take(2)
                            .map((s) => _SessionCard(session: s))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Progress
                  _SectionHeader(
                    title: 'Son İlerleme',
                    onSeeAll: () => context.go(AppRoutes.progress),
                  ),
                  const SizedBox(height: 12),
                  progressAsync.when(
                    loading: () => const AppLoading(size: 32),
                    error: (e, _) => Text('Hata: $e'),
                    data: (progress) {
                      if (progress == null) {
                        return _EmptyCard(
                          icon: Icons.trending_up_outlined,
                          message: 'İlerleme kaydı yok',
                          actionLabel: 'Kaydet',
                          onAction: () => context.go(AppRoutes.addProgress),
                        );
                      }
                      return _ProgressCard(progress: progress);
                    },
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String memberId;

  const _QuickActions({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionButton(
          icon: Icons.calendar_month,
          label: 'Randevu Al',
          onTap: () => context.go(AppRoutes.booking),
        ),
        const SizedBox(width: 12),
        _QuickActionButton(
          icon: Icons.fitness_center,
          label: 'Programım',
          onTap: () => context.go(AppRoutes.memberPrograms),
        ),
        const SizedBox(width: 12),
        _QuickActionButton(
          icon: Icons.trending_up,
          label: 'İlerleme',
          onTap: () => context.go(AppRoutes.progress),
        ),
        const SizedBox(width: 12),
        _QuickActionButton(
          icon: Icons.chat_outlined,
          label: 'Mesaj',
          onTap: () => context.go(AppRoutes.chatList),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Tümü')),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.dateTime.formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.dateTime.formattedDayMonth,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${session.durationMinutes} dk seans'),
        trailing: StatusBadge.session(session.status),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ProgressModel progress;

  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.trending_up, size: 36, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.date.formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (progress.weight != null)
                    Text(
                      '${progress.weight} kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (progress.weight != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.weight} kg',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Son kilo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
