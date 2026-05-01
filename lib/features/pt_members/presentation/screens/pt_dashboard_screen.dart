import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_calendar/providers/pt_calendar_provider.dart';
import '../../../../shared/models/member_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

class PtDashboardScreen extends ConsumerWidget {
  const PtDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _DashboardContent(ptId: user.uid, ptName: user.name);
      },
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final String ptId;
  final String ptName;

  const _DashboardContent({required this.ptId, required this.ptName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(ptMembersProvider(ptId));
    final sessionsAsync = ref.watch(upcomingSessionsProvider(ptId));
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ptMembersProvider(ptId));
          ref.invalidate(upcomingSessionsProvider(ptId));
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 120,
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
                              'Merhaba, ${ptName.split(' ').first}!',
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
                        child: Consumer(
                          builder: (context, ref, _) {
                            final userAsync = ref.watch(currentUserProvider);
                            final user = userAsync.valueOrNull;
                            return UserAvatar(
                              photoUrl: user?.photoUrl,
                              name: ptName,
                              radius: 22,
                            );
                          },
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
                  // Stats Row
                  _StatsRow(ptId: ptId),
                  const SizedBox(height: 24),

                  // Upcoming Sessions
                  _SectionHeader(
                    title: 'Yaklaşan Seanslar',
                    onSeeAll: () => context.go(AppRoutes.ptCalendar),
                  ),
                  const SizedBox(height: 12),
                  sessionsAsync.when(
                    loading: () => const AppLoading(size: 32),
                    error: (e, _) => Text('Hata: $e'),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.calendar_today_outlined,
                          message: 'Yaklaşan seans yok',
                        );
                      }
                      return Column(
                        children: sessions
                            .take(3)
                            .map((s) => _SessionCard(session: s))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recent Members
                  _SectionHeader(
                    title: 'Son Üyeler',
                    onSeeAll: () => context.go(AppRoutes.ptMembers),
                  ),
                  const SizedBox(height: 12),
                  membersAsync.when(
                    loading: () => const AppLoading(size: 32),
                    error: (e, _) => Text('Hata: $e'),
                    data: (members) {
                      if (members.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.people_outline,
                          message: 'Henüz üye yok',
                        );
                      }
                      return Column(
                        children: members
                            .take(3)
                            .map((m) => _MemberCard(member: m))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.ptCalendar),
        icon: const Icon(Icons.add),
        label: const Text('Seans Ekle'),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String ptId;

  const _StatsRow({required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(ptMembersProvider(ptId));
    final sessionsAsync = ref.watch(upcomingSessionsProvider(ptId));

    final memberCount = membersAsync.valueOrNull?.length ?? 0;
    final sessionCount = sessionsAsync.valueOrNull?.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Toplam Üye',
            value: memberCount.toString(),
            icon: Icons.people,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Bu Hafta',
            value: sessionCount.toString(),
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Aktif',
            value: memberCount.toString(),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
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
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Tümünü Gör'),
          ),
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
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.fitness_center,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          session.memberName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(session.dateTime.formattedDateTime),
        trailing: StatusBadge.session(session.status),
        onTap: () =>
            context.push('/pt/calendar/${session.id}'),
      ),
    );
  }
}

class _MemberCard extends ConsumerWidget {
  final MemberProfile member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrl = member.photoUrl ??
        ref.watch(ptUserProvider(member.memberId)).valueOrNull?.photoUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: UserAvatar(
          photoUrl: photoUrl,
          name: member.name,
          radius: 22,
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(member.goal ?? 'Hedef belirtilmemiş'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${member.remainingSessions}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
            Text(
              'seans',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () =>
            context.push('/pt/members/${member.memberId}'),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(width: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
