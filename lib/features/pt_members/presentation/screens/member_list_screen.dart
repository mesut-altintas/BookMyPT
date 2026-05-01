import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/models/member_model.dart';
import '../../../pt_members/providers/pt_members_provider.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen>
    with SingleTickerProviderStateMixin {
  String _search = '';
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
        return _buildScaffold(context, ref, user.uid);
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context, WidgetRef ref, String ptId) {
    final membersAsync = ref.watch(ptMembersProvider(ptId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Üyelerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push(AppRoutes.addMember),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Üye ara...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tümü'),
                  Tab(text: 'Aktif'),
                  Tab(text: 'Pasif'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      body: membersAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(
          message: e.toString(),
          onRetry: () => ref.invalidate(ptMembersProvider(ptId)),
        ),
        data: (members) {
          // Filter by tab
          List<MemberProfile> tabFiltered;
          switch (_tabController.index) {
            case 1:
              tabFiltered = members.where((m) => m.isActive).toList();
              break;
            case 2:
              tabFiltered = members.where((m) => !m.isActive).toList();
              break;
            default:
              tabFiltered = members;
          }

          final filtered = _search.isEmpty
              ? tabFiltered
              : tabFiltered
                  .where((m) =>
                      m.name.toLowerCase().contains(_search) ||
                      m.email.toLowerCase().contains(_search))
                  .toList();

          if (members.isEmpty) {
            return AppEmpty(
              message: 'Henüz üyeniz yok',
              subMessage: 'Üye eklemek için + butonuna tıklayın',
              icon: Icons.people_outline,
              action: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addMember),
                icon: const Icon(Icons.person_add),
                label: const Text('Üye Ekle'),
              ),
            );
          }

          if (filtered.isEmpty) {
            return const AppEmpty(
              message: 'Arama sonucu bulunamadı',
              icon: Icons.search_off,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ptMembersProvider(ptId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final member = filtered[i];
                return _MemberListTile(
                  member: member,
                  ptId: ptId,
                  onTap: () => context.push('/pt/members/${member.memberId}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addMember),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _MemberListTile extends ConsumerWidget {
  final MemberProfile member;
  final String ptId;
  final VoidCallback onTap;

  const _MemberListTile({
    required this.member,
    required this.ptId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final photoUrl = member.photoUrl ??
        ref.watch(ptUserProvider(member.memberId)).valueOrNull?.photoUrl;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(photoUrl: photoUrl, name: member.name, radius: 24),
            if (!member.isActive)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name.isNotEmpty ? member.name : member.email,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: member.isActive ? null : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (!member.isActive)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pasif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.goal != null && member.goal!.isNotEmpty)
              Text(member.goal!, maxLines: 1, overflow: TextOverflow.ellipsis)
            else
              Text(member.email, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${member.remainingSessions}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: member.remainingSessions > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
            Text(
              'kalan seans',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
