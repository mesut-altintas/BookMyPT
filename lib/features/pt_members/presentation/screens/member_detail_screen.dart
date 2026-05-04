import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../../../../shared/models/member_model.dart';
import '../../../../shared/models/session_model.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../pt_members/providers/pt_members_provider.dart';
import '../../../pt_programs/providers/pt_programs_provider.dart';
import '../../../pt_calendar/providers/pt_calendar_provider.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _buildContent(context, ref, user.uid);
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, String ptId) {
    final memberAsync = ref.watch(ptMemberDetailProvider(
        (ptId: ptId, memberId: widget.memberId)));

    return memberAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: AppError(message: e.toString())),
      data: (member) {
        if (member == null) {
          return const Scaffold(body: Center(child: Text('Üye bulunamadı')));
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _MemberHeader(member: member),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.chat_outlined),
                    tooltip: 'Mesaj Gönder',
                    onPressed: () async {
                      final user = ref.read(currentUserProvider).valueOrNull;
                      if (user == null) return;
                      try {
                        final chatId = await ref
                            .read(chatRepositoryProvider)
                            .createOrGetChatRoom(
                              ptId: ptId,
                              memberId: widget.memberId,
                              ptName: user.name,
                              memberName: member.name,
                              ptPhotoUrl: user.photoUrl,
                              memberPhotoUrl: member.photoUrl,
                            );
                        if (context.mounted) context.go('/pt/chat/$chatId');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Mesaj açılamadı: $e'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },
                  ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              member.isActive
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(member.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'toggle') {
                        await ref
                            .read(memberRepositoryProvider)
                            .updateMember(
                              ptId: ptId,
                              memberId: widget.memberId,
                              data: {'isActive': !member.isActive},
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(member.isActive
                                  ? '${member.name} pasif yapıldı'
                                  : '${member.name} aktif yapıldı'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else if (value == 'remove') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          useRootNavigator: false,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Üyeyi Sil'),
                            content: Text(
                                '${member.name} kalıcı olarak silinecek. Bu işlem geri alınamaz.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, false),
                                child: const Text('İptal'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Sil'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          final repo = ref.read(memberRepositoryProvider);
                          try {
                            await repo.removeMember(
                              ptId: ptId,
                              memberId: widget.memberId,
                            );
                            if (context.mounted) context.pop();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Silme hatası: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'Programlar'),
                    Tab(text: 'Seanslar'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(member: member, ptId: ptId),
                _ProgramsTab(memberId: widget.memberId, ptId: ptId),
                _SessionsTab(memberId: widget.memberId, ptId: ptId),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MemberHeader extends ConsumerWidget {
  final MemberProfile member;

  const _MemberHeader({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photoUrl = member.photoUrl ??
        ref.watch(ptUserProvider(member.memberId)).valueOrNull?.photoUrl;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          UserAvatar(
            photoUrl: photoUrl,
            name: member.name,
            radius: 36,
          ),
          const SizedBox(height: 12),
          Text(
            member.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: member.remainingSessions > 0
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                '${member.remainingSessions} seans kaldı',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final MemberProfile member;
  final String ptId;

  const _OverviewTab({required this.member, required this.ptId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Hedef',
          value: member.goal ?? 'Belirtilmemiş',
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'E-posta',
          value: member.email,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        if (member.phone != null)
          _InfoCard(
            title: 'Telefon',
            value: member.phone!,
            icon: Icons.phone_outlined,
          ),
        if (member.phone != null) const SizedBox(height: 12),
        if (member.height != null)
          _InfoCard(
            title: 'Boy',
            value: '${member.height} cm',
            icon: Icons.height,
          ),
        if (member.height != null) const SizedBox(height: 12),
        if (member.startingWeight != null)
          _InfoCard(
            title: 'Başlangıç Kilosu',
            value: '${member.startingWeight} kg',
            icon: Icons.monitor_weight_outlined,
          ),
        if (member.startingWeight != null) const SizedBox(height: 12),
        _InfoCard(
          title: 'Katılım Tarihi',
          value: member.joinedAt.formattedDate,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 12),
        if (member.notes != null && member.notes!.isNotEmpty)
          _InfoCard(
            title: 'Notlar',
            value: member.notes!,
            icon: Icons.notes_outlined,
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramsTab extends ConsumerWidget {
  final String memberId;
  final String ptId;

  const _ProgramsTab({required this.memberId, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(
        ptMemberProgramsProvider((ptId: ptId, memberId: memberId)));

    return programsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppError(message: e.toString()),
      data: (programs) {
        if (programs.isEmpty) {
          return const AppEmpty(
            message: 'Henüz program yok',
            icon: Icons.fitness_center_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: programs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = programs[i];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              leading: const Icon(Icons.fitness_center),
              title: Text(p.title),
              subtitle: Text('${p.weeks.length} Hafta'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/pt/programs/${p.id}'),
            );
          },
        );
      },
    );
  }
}

class _SessionsTab extends ConsumerWidget {
  final String memberId;
  final String ptId;

  const _SessionsTab({required this.memberId, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(
        ptMemberSessionsProvider((ptId: ptId, memberId: memberId)));

    return sessionsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppError(message: e.toString()),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const AppEmpty(
            message: 'Henüz seans yok',
            icon: Icons.calendar_today_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = sessions[i];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.event),
              title: Text(s.dateTime.formattedDateTime),
              subtitle: Text('${s.durationMinutes} dk'),
              trailing: _SessionStatusChip(status: s.status),
            );
          },
        );
      },
    );
  }
}

class _SessionStatusChip extends StatelessWidget {
  final SessionStatus status;

  const _SessionStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
