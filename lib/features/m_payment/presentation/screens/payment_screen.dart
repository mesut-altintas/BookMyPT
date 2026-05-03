import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../providers/payment_provider.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _PaymentContent(memberId: user.uid, ptId: user.ptId);
      },
    );
  }
}

class _PaymentContent extends ConsumerWidget {
  final String memberId;
  final String? ptId;

  const _PaymentContent({required this.memberId, this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPt = ptId != null && ptId!.isNotEmpty;
    final memberDetailAsync = hasPt
        ? ref.watch(ptMemberDetailProvider((ptId: ptId!, memberId: memberId)))
        : const AsyncValue<dynamic>.data(null);
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));
    final packagesAsync = hasPt
        ? ref.watch(ptPackagesProvider(ptId!))
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

    return Scaffold(
      appBar: AppBar(title: const Text('Paketlerim')),
      body: memberDetailAsync.isLoading
          ? const AppLoading()
          : CustomScrollView(
              slivers: [
                // ── Section 1: Seans Durumu ──────────────────────────────
                SliverToBoxAdapter(
                  child: _SessionStatusCard(
                    remainingSessions: remainingSessions,
                    hasPt: hasPt,
                  ),
                ),

                // Bekleyen ödemeler
                if (pendingPayments.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Onay Bekliyor',
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

                // Son işlemler
                if (recentPayments.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Son İşlemler',
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

                // ── Section 2: Paket Satın Al ────────────────────────────
                if (!hasPt)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: payments.isEmpty
                        ? const AppEmpty(
                            message: 'PT atanmamış',
                            subMessage:
                                'PT\'niz sizi sisteme ekledikten sonra paketleri görebilirsiniz',
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
                        title: 'Paket Satın Al',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  )
                else ...[
                  _SectionHeader(
                    title: 'Paket Satın Al',
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
            ),
    );
  }
}

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
                    'kalan seans hakkı',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!hasPt)
                    Text(
                      'PT atanmamış',
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
                      Text('${package.sessionCount} seans',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
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
                child: const Text('Satın Al'),
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
        title: const Text('Paket Satın Al'),
        content: Text(
          '${package.name} paketini ${package.price.formattedCurrency} karşılığında satın almak istiyor musunuz?\n\n'
          '${package.sessionCount} seans hakkı PT onayından sonra hesabınıza yüklenecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Onayla'),
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
          const SnackBar(
            content: Text(
                'Ödeme talebiniz oluşturuldu. PT\'niz onayladığında seans hakkınız yüklenecektir.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
