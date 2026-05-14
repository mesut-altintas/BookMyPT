import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_groups/providers/pt_groups_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/group_model.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../providers/payment_provider.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myPackages),
            bottom: TabBar(
              controller: _tab,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person_outline, size: 18),
                  text: l10n.individual,
                ),
                Tab(
                  icon: const Icon(Icons.groups_outlined, size: 18),
                  text: l10n.groupPackages,
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _IndividualTab(memberId: user.uid, ptId: user.ptId),
              _GroupPackagesTab(
                memberId: user.uid,
                memberName: user.name,
                ptId: user.ptId,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Individual Packages Tab ──────────────────────────────────────────────────

class _IndividualTab extends ConsumerWidget {
  final String memberId;
  final String? ptId;

  const _IndividualTab({required this.memberId, this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPt = ptId != null && ptId!.isNotEmpty;
    final memberDetailAsync = hasPt
        ? ref.watch(ptMemberDetailProvider((ptId: ptId!, memberId: memberId)))
        : const AsyncValue<dynamic>.data(null);
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));
    final packagesAsync = hasPt
        ? ref.watch(memberFacingPackagesProvider(
            (ptId: ptId!, memberId: memberId)))
        : const AsyncValue<List<PackageModel>>.data([]);

    final remainingSessions =
        (memberDetailAsync.valueOrNull?.remainingSessions as int?) ?? 0;
    final payments = paymentsAsync.valueOrNull ?? [];
    final packages = packagesAsync.valueOrNull ?? [];

    final pendingPayments =
        payments.where((p) => p.status == PaymentStatus.pending).toList();
    final recentPayments = payments
        .where((p) => p.status != PaymentStatus.pending)
        .take(5)
        .toList();

    return memberDetailAsync.isLoading
        ? const AppLoading()
        : CustomScrollView(
            slivers: [
              // ── Session Status ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SessionStatusCard(
                  remainingSessions: remainingSessions,
                  hasPt: hasPt,
                ),
              ),

              // Pending payments
              if (pendingPayments.isNotEmpty) ...[
                _SectionHeader(
                  title: context.l10n.pendingApproval,
                  icon: Icons.hourglass_top_outlined,
                  color: Colors.orange,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _PaymentCard(payment: pendingPayments[i]),
                    ),
                    childCount: pendingPayments.length,
                  ),
                ),
              ],

              // Recent transactions
              if (recentPayments.isNotEmpty) ...[
                _SectionHeader(
                  title: context.l10n.recentTransactions,
                  icon: Icons.history,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _PaymentCard(payment: recentPayments[i]),
                    ),
                    childCount: recentPayments.length,
                  ),
                ),
              ],

              // ── Buy Package ──────────────────────────────────────────────
              if (!hasPt)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: payments.isEmpty
                      ? AppEmpty(
                          message: context.l10n.noPtAssigned,
                          subMessage: context.l10n.noPtPackagesSub,
                          icon: Icons.person_off_outlined,
                        )
                      : const SizedBox.shrink(),
                )
              else if (packagesAsync.isLoading)
                const SliverToBoxAdapter(child: AppLoading())
              else if (packages.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _SectionHeader(
                      title: context.l10n.buyPackage,
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                )
              else ...[
                _SectionHeader(
                  title: context.l10n.buyPackage,
                  icon: Icons.inventory_2_outlined,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _PackageCard(
                          package: packages[i], memberId: memberId),
                    ),
                    childCount: packages.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ],
          );
  }
}

// ─── Group Packages Tab ───────────────────────────────────────────────────────

class _GroupPackagesTab extends ConsumerWidget {
  final String memberId;
  final String memberName;
  final String? ptId;

  const _GroupPackagesTab({
    required this.memberId,
    required this.memberName,
    this.ptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (ptId == null || ptId!.isEmpty) {
      return AppEmpty(
        message: l10n.noPtAssigned,
        subMessage: l10n.noPtPackagesSub,
        icon: Icons.person_off_outlined,
      );
    }

    final groupsAsync = ref.watch(ptGroupsProvider(ptId!));
    final packagesAsync = ref.watch(allActiveGroupPackagesProvider(ptId!));
    final groupPaymentsAsync =
        ref.watch(memberGroupPaymentsProvider(memberId));

    if (groupsAsync.isLoading || packagesAsync.isLoading) {
      return const AppLoading();
    }

    final allGroups = groupsAsync.valueOrNull ?? [];
    final allPackages = packagesAsync.valueOrNull ?? [];
    final myPayments = groupPaymentsAsync.valueOrNull ?? [];

    // Only groups the member belongs to
    final myGroups =
        allGroups.where((g) => g.memberIds.contains(memberId)).toList();

    if (myGroups.isEmpty) {
      return AppEmpty(
        message: l10n.notInAnyGroup,
        icon: Icons.groups_outlined,
      );
    }

    // Packages for groups the member is in
    final myGroupIds = myGroups.map((g) => g.id).toSet();
    final myGroupPackages =
        allPackages.where((p) => myGroupIds.contains(p.groupId)).toList();

    if (myGroupPackages.isEmpty) {
      return AppEmpty(
        message: l10n.noGroupPackagesYet,
        icon: Icons.inventory_2_outlined,
      );
    }

    // Build a map of purchased (pending/completed) package IDs for quick lookup
    final purchasedIds = myPayments
        .where((p) =>
            p.status == 'pending' || p.status == 'completed')
        .map((p) => p.groupPackageId)
        .toSet();

    // Group packages by groupId for display
    final packagesByGroup = <String, List<GroupPackage>>{};
    for (final pkg in myGroupPackages) {
      packagesByGroup.putIfAbsent(pkg.groupId, () => []).add(pkg);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myGroups.length,
      itemBuilder: (context, i) {
        final group = myGroups[i];
        final groupPkgs = packagesByGroup[group.id] ?? [];
        if (groupPkgs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Padding(
              padding: EdgeInsets.only(bottom: 8, top: i == 0 ? 0 : 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(group.colorValue),
                    child: const Icon(Icons.groups,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            // Packages for this group
            ...groupPkgs.map((pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GroupPackageCard(
                    package: pkg,
                    group: group,
                    memberId: memberId,
                    memberName: memberName,
                    alreadyPurchased: purchasedIds.contains(pkg.id),
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _GroupPackageCard extends ConsumerWidget {
  final GroupPackage package;
  final GroupModel group;
  final String memberId;
  final String memberName;
  final bool alreadyPurchased;

  const _GroupPackageCard({
    required this.package,
    required this.group,
    required this.memberId,
    required this.memberName,
    required this.alreadyPurchased,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final groupColor = Color(group.colorValue);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alreadyPurchased
              ? Colors.green.withOpacity(0.4)
              : groupColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: groupColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.groups, color: groupColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        '${package.sessionCount} ${l10n.sessions}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.pricePerMember.formattedCurrency,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: groupColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.perMember,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: alreadyPurchased
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      label: Text(
                        l10n.alreadyPurchased,
                        style: const TextStyle(color: Colors.green),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _purchase(context, ref),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: groupColor),
                      child: Text(l10n.purchase,
                          style: const TextStyle(color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.buyPackage),
        content: Text(
          l10n.groupPurchaseConfirm(
            package.name,
            group.name,
            package.pricePerMember.formattedCurrency,
            package.sessionCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(groupRepositoryProvider).purchaseGroupPackage(
            package: package,
            group: group,
            memberId: memberId,
            memberName: memberName,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentRequestCreated),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error('$e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SessionStatusCard extends StatelessWidget {
  final int remainingSessions;
  final bool hasPt;

  const _SessionStatusCard(
      {required this.remainingSessions, required this.hasPt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = remainingSessions > 0
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: color.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$remainingSessions',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.remainingSessionRights,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!hasPt)
                    Text(
                      context.l10n.noPtAssigned,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
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
  final IconData? icon;
  final Color? color;

  const _SectionHeader({required this.title, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: c),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: c,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isPending = payment.status == PaymentStatus.pending;
    final statusColor = isPending ? Colors.orange : Colors.green;

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPending ? Icons.hourglass_top : Icons.check_circle_outline,
            color: statusColor,
            size: 22,
          ),
        ),
        title: Text(payment.packageName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${payment.sessionCount} seans • ${DateFormat('d MMM y', 'tr').format(payment.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payment.amount.formattedCurrency,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                payment.status.label,
                style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends ConsumerWidget {
  final PackageModel package;
  final String memberId;

  const _PackageCard({required this.package, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                        package.sessionDurationMinutes != null
                            ? '${package.sessionCount} seans • ${package.sessionDurationMinutes} dk/seans'
                            : '${package.sessionCount} seans',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.price.formattedCurrency,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (package.description != null &&
                package.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(package.description!,
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _purchase(context, ref),
                child: Text(context.l10n.purchase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.buyPackage),
        content: Text(
          context.l10n.purchaseDialogContent(
            package.name,
            package.price.formattedCurrency,
            package.sessionCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(paymentRepositoryProvider).createPayment(
            PaymentModel(
              id: '',
              memberId: memberId,
              ptId: package.ptId,
              amount: package.price,
              currency: package.currency,
              status: PaymentStatus.pending,
              packageName: package.name,
              sessionCount: package.sessionCount,
              createdAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.paymentRequestCreated),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error('$e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
