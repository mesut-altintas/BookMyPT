import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/presentation/screens/chat_screen.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../../../../features/pt_groups/providers/pt_groups_provider.dart';
import '../../../../shared/models/group_model.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'group_session_screen.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupSnap = ref.watch(ptGroupsProvider(
        ref.watch(currentUserProvider).valueOrNull?.uid ?? ''));
    final group = groupSnap.valueOrNull
        ?.where((g) => g.id == widget.groupId)
        .firstOrNull;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final groupColor =
        group != null ? Color(group.colorValue) : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? l10n.group),
        backgroundColor: groupColor,
        foregroundColor: Colors.white,
        actions: [
          if (group != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await context.push(AppRoutes.createGroup, extra: group);
              },
            ),
          if (group != null)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'delete') {
                  final confirmed = await _confirmDelete(context, l10n);
                  if (confirmed == true) {
                    await ref
                        .read(groupRepositoryProvider)
                        .deleteGroup(widget.groupId);
                    if (context.mounted) context.pop();
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteGroup,
                        style: const TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.people, size: 18), text: l10n.members),
            Tab(icon: const Icon(Icons.inventory_2_outlined, size: 18), text: l10n.packages),
            Tab(icon: const Icon(Icons.calendar_today_outlined, size: 18), text: l10n.sessions),
            Tab(icon: const Icon(Icons.chat_outlined, size: 18), text: l10n.navChat),
          ],
        ),
      ),
      body: group == null
          ? const AppLoading()
          : TabBarView(
              controller: _tab,
              children: [
                _MembersTab(group: group, groupColor: groupColor),
                _PackagesTab(group: group, groupColor: groupColor),
                _SessionsTab(group: group, groupColor: groupColor),
                _ChatTab(group: group),
              ],
            ),
      floatingActionButton: group == null
          ? null
          : _buildFab(context, group, l10n),
    );
  }

  Widget? _buildFab(BuildContext ctx, GroupModel group, dynamic l10n) {
    return AnimatedBuilder(
      animation: _tab,
      builder: (_, __) {
        if (_tab.index == 1) {
          // Packages tab — add package
          return FloatingActionButton.extended(
            onPressed: () => _showAddPackageDialog(ctx, group),
            icon: const Icon(Icons.add),
            label: Text(l10n.addPackage),
          );
        }
        if (_tab.index == 2) {
          // Sessions tab — create session
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(
              builder: (_) => GroupSessionScreen(group: group),
            )),
            icon: const Icon(Icons.add),
            label: Text(l10n.newSession),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext ctx, dynamic l10n) =>
      showDialog<bool>(
        context: ctx,
        builder: (d) => AlertDialog(
          title: Text(l10n.deleteGroup),
          content: Text(l10n.deleteGroupConfirm),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text(l10n.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

  Future<void> _showAddPackageDialog(
      BuildContext ctx, GroupModel group) async {
    final l10n = ctx.l10n;
    final nameCtrl = TextEditingController();
    final sessionCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text(l10n.addPackage),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration:
                    InputDecoration(labelText: l10n.packageName),
                validator: (v) => v == null || v.isEmpty ? l10n.required : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: sessionCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: l10n.sessionCount),
                validator: (v) => v == null || int.tryParse(v) == null
                    ? l10n.required
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: '${l10n.price} (₺)'),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? l10n.required
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(d);
              await ref.read(groupRepositoryProvider).createGroupPackage(
                    ptId: group.ptId,
                    groupId: group.id,
                    name: nameCtrl.text.trim(),
                    sessionCount: int.parse(sessionCtrl.text.trim()),
                    pricePerMember:
                        double.parse(priceCtrl.text.trim()),
                  );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

// ─── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final GroupModel group;
  final Color groupColor;

  const _MembersTab({required this.group, required this.groupColor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (group.memberIds.isEmpty) {
      return AppEmpty(
          message: l10n.noMembersInGroup, icon: Icons.people_outline);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: group.memberIds.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final uid = group.memberIds[i];
        final name = group.memberNames[uid] ?? uid;
        return ListTile(
          leading: UserAvatar(name: name, radius: 22),
          title: Text(name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: CircleAvatar(
            radius: 6,
            backgroundColor: groupColor,
          ),
        );
      },
    );
  }
}

// ─── Packages Tab ─────────────────────────────────────────────────────────────

class _PackagesTab extends ConsumerWidget {
  final GroupModel group;
  final Color groupColor;

  const _PackagesTab({required this.group, required this.groupColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkgsAsync = ref.watch(groupPackagesProvider(group.id));
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return pkgsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (packages) {
        if (packages.isEmpty) {
          return AppEmpty(
              message: l10n.noPackagesYet,
              icon: Icons.inventory_2_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          itemBuilder: (_, i) {
            final pkg = packages[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: pkg.isActive
                        ? groupColor.withOpacity(0.5)
                        : theme.dividerColor),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pkg.isActive
                      ? groupColor
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Text('${pkg.sessionCount}',
                      style: TextStyle(
                          color: pkg.isActive
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700)),
                ),
                title: Text(pkg.name),
                subtitle: Text(
                  '${pkg.pricePerMember.toStringAsFixed(0)} ₺ / ${l10n.perMember}',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                trailing: pkg.isActive
                    ? IconButton(
                        icon: const Icon(Icons.pause_circle_outline),
                        tooltip: l10n.deactivate,
                        onPressed: () => ref
                            .read(groupRepositoryProvider)
                            .deactivateGroupPackage(pkg.id),
                      )
                    : Chip(
                        label: Text(l10n.inactive,
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Sessions Tab ─────────────────────────────────────────────────────────────

class _SessionsTab extends ConsumerWidget {
  final GroupModel group;
  final Color groupColor;

  const _SessionsTab({required this.group, required this.groupColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(groupSessionsProvider(group.id));
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return sessionsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (sessions) {
        if (sessions.isEmpty) {
          return AppEmpty(
              message: l10n.noSessionsYet,
              icon: Icons.calendar_today_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (_, i) {
            final s = sessions[i];
            final statusColor = s.isCompleted
                ? Colors.green
                : s.isCancelled
                    ? Colors.red
                    : groupColor;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      GroupSessionScreen(group: group, session: s),
                )),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(Icons.fitness_center, color: statusColor),
                ),
                title: Text(s.dateTime.formattedDate,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${s.durationMinutes} dk • '
                  '${s.attendedCount}/${s.memberIds.length} ${l10n.attended}',
                ),
                trailing: _StatusChip(session: s, l10n: l10n, theme: theme),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final GroupSession session;
  final dynamic l10n;
  final ThemeData theme;

  const _StatusChip(
      {required this.session, required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (session.isCompleted) {
      return Chip(
        label: Text(l10n.completed,
            style: const TextStyle(color: Colors.white, fontSize: 11)),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
      );
    }
    if (session.isCancelled) {
      return Chip(
        label: Text(l10n.cancelled,
            style: const TextStyle(color: Colors.white, fontSize: 11)),
        backgroundColor: Colors.red,
        padding: EdgeInsets.zero,
      );
    }
    return Chip(
      label: Text(l10n.scheduled,
          style: TextStyle(
              color: theme.colorScheme.primary, fontSize: 11)),
      backgroundColor: theme.colorScheme.primaryContainer,
      padding: EdgeInsets.zero,
    );
  }
}

// ─── Chat Tab ─────────────────────────────────────────────────────────────────

class _ChatTab extends ConsumerWidget {
  final GroupModel group;

  const _ChatTab({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    if (user == null) return const AppLoading();

    final chatId = ref.read(chatRepositoryProvider).getGroupChatId(group.id);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.chat, size: 36),
          ),
          const SizedBox(height: 16),
          Text(group.name,
              style: Theme.of(context).textTheme.titleMedium),
          Text(
            '${group.memberIds.length + 1} ${context.l10n.participants}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              // Ensure the chat room document exists with participants field
              // (handles groups created before the group-chat feature was added)
              await ref.read(chatRepositoryProvider).createOrUpdateGroupChatRoom(
                groupId: group.id,
                groupName: group.name,
                ptId: group.ptId,
                memberIds: group.memberIds,
              );
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(chatId: chatId),
                  ),
                );
              }
            },
            icon: const Icon(Icons.chat_outlined),
            label: Text(context.l10n.openChat),
          ),
        ],
      ),
    );
  }
}
