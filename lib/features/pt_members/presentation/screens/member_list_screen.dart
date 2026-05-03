import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_calendar/providers/invitation_provider.dart';
import '../../../../shared/models/invitation_model.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
    final requestCount = ref.watch(ptPendingRequestsCountProvider);

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
                tabs: [
                  const Tab(text: 'Tümü'),
                  const Tab(text: 'Aktif'),
                  const Tab(text: 'Pasif'),
                  Tab(
                    child: requestCount > 0
                        ? badges.Badge(
                            badgeContent: Text('$requestCount',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('İstekler'),
                            ),
                          )
                        : const Text('İstekler'),
                  ),
                ],
                onTap: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      body: _tabController.index == 3
          ? _MemberRequestsTab(ptId: ptId)
          : membersAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppError(
                message: e.toString(),
                onRetry: () => ref.invalidate(ptMembersProvider(ptId)),
              ),
              data: (members) {
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
                        onTap: () =>
                            context.push('/pt/members/${member.memberId}'),
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

class _MemberRequestsTab extends ConsumerWidget {
  final String ptId;
  const _MemberRequestsTab({required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(ptMemberRequestsProvider);

    return requestsAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppError(message: e.toString()),
      data: (requests) {
        if (requests.isEmpty) {
          return const AppEmpty(
            message: 'Bekleyen istek yok',
            subMessage: 'Üyeler size katılmak için istek gönderdiğinde burada görünür',
            icon: Icons.person_add_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _MemberRequestCard(
            request: requests[i],
            ptId: ptId,
          ),
        );
      },
    );
  }
}

class _MemberRequestCard extends ConsumerStatefulWidget {
  final InvitationModel request;
  final String ptId;
  const _MemberRequestCard({required this.request, required this.ptId});

  @override
  ConsumerState<_MemberRequestCard> createState() => _MemberRequestCardState();
}

class _MemberRequestCardState extends ConsumerState<_MemberRequestCard> {
  bool _loading = false;

  Future<void> _respond(bool accept) async {
    setState(() => _loading = true);
    try {
      final invRepo = ref.read(invitationRepositoryProvider);
      final isActivation = widget.request.type == InvitationType.activation;
      if (accept) {
        if (isActivation) {
          // Activate the member in PT's subcollection
          await ref.read(memberRepositoryProvider).updateMember(
            ptId: widget.ptId,
            memberId: widget.request.memberId!,
            data: {'isActive': true},
          );
          await invRepo.rejectInvitation(widget.request.id); // close the request
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${widget.request.memberName ?? widget.request.memberEmail} aktif hale getirildi'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        } else {
          final memberRepo = ref.read(memberRepositoryProvider);
          await invRepo.acceptInvitation(
            invitation: widget.request,
            memberRepo: memberRepo,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${widget.request.memberName ?? widget.request.memberEmail} üye olarak eklendi'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      } else {
        await invRepo.rejectInvitation(widget.request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('İstek reddedildi'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final req = widget.request;
    final displayName = req.memberName?.isNotEmpty == true
        ? req.memberName!
        : req.memberEmail;

    final isActivation = req.type == InvitationType.activation;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActivation
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.secondaryContainer,
                  child: Icon(
                    isActivation ? Icons.play_circle_outline : Icons.person_add_outlined,
                    color: isActivation
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        isActivation ? 'Aktivasyon isteği' : 'Katılım isteği',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _respond(false),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error),
                          child: const Text('Reddet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respond(true),
                          child: const Text('Kabul Et'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
