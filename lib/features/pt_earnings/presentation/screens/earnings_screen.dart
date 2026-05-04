import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';
import '../../../m_payment/providers/payment_provider.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _EarningsContent(ptId: user.uid);
      },
    );
  }
}

class _EarningsContent extends ConsumerWidget {
  final String ptId;

  const _EarningsContent({required this.ptId});

  double _totalEarnings(List<PaymentModel> payments) => payments
      .where((p) => p.status == PaymentStatus.completed)
      .fold(0.0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(ptPaymentsProvider(ptId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.push(AppRoutes.packageManagement),
            tooltip: 'Paket Yönetimi',
          ),
        ],
      ),
      body: paymentsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (payments) {
          final total = _totalEarnings(payments);
          final pendingPayments =
              payments.where((p) => p.status == PaymentStatus.pending).toList();
          final completedPayments =
              payments.where((p) => p.status == PaymentStatus.completed).toList();
          final otherPayments = payments
              .where((p) =>
                  p.status != PaymentStatus.pending &&
                  p.status != PaymentStatus.completed)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Toplam Gelir',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              total.formattedCurrency,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _StatChip(
                                  label: '${completedPayments.length} Ödeme',
                                  icon: Icons.check_circle_outline,
                                ),
                                const SizedBox(width: 8),
                                _StatChip(
                                  label: '${pendingPayments.length} Bekleyen',
                                  icon: Icons.schedule,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (completedPayments
                              .map((p) => p.createdAt.month)
                              .toSet()
                              .length >
                          1) ...[
                        const SizedBox(height: 20),
                        _MonthlyChart(payments: completedPayments),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Onay Bekleyen Ödemeler ────────────────────────────────
              if (pendingPayments.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.pending_actions,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'Onay Bekleyen (${pendingPayments.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _PendingPaymentCard(
                        payment: pendingPayments[i],
                        ptId: ptId,
                      ),
                      childCount: pendingPayments.length,
                    ),
                  ),
                ),
              ],

              // ── İşlem Geçmişi ─────────────────────────────────────────
              if (payments.isEmpty)
                SliverFillRemaining(
                  child: AppEmpty(
                    message: 'Henüz ödeme yok',
                    subMessage:
                        'Üyeleriniz paket satın aldığında burada görünür',
                    icon: Icons.account_balance_wallet_outlined,
                    action: ElevatedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.packageManagement),
                      icon: const Icon(Icons.add),
                      label: const Text('Paket Oluştur'),
                    ),
                  ),
                )
              else if (completedPayments.isNotEmpty ||
                  otherPayments.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      'İşlem Geçmişi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final list = [...completedPayments, ...otherPayments];
                        return _PaymentTile(payment: list[i], ptId: ptId);
                      },
                      childCount:
                          completedPayments.length + otherPayments.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<PaymentModel> payments;

  const _MonthlyChart({required this.payments});

  @override
  Widget build(BuildContext context) {
    final Map<int, double> monthly = {};
    for (final p in payments) {
      final month = p.createdAt.month;
      monthly[month] = (monthly[month] ?? 0) + p.amount;
    }

    final spots = monthly.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const months = [
                    '', 'Oc', 'Şb', 'Mr', 'Ns', 'My', 'Hz',
                    'Tm', 'Ağ', 'Ey', 'Ek', 'Ks', 'Ar'
                  ];
                  return Text(
                    months[v.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingPaymentCard extends ConsumerStatefulWidget {
  final PaymentModel payment;
  final String ptId;

  const _PendingPaymentCard({required this.payment, required this.ptId});

  @override
  ConsumerState<_PendingPaymentCard> createState() =>
      _PendingPaymentCardState();
}

class _PendingPaymentCardState extends ConsumerState<_PendingPaymentCard> {
  bool _loading = false;

  String _memberName() {
    final memberAsync = ref.watch(
      ptMemberDetailProvider((ptId: widget.ptId, memberId: widget.payment.memberId)),
    );
    return memberAsync.valueOrNull?.name ?? widget.payment.memberId;
  }

  Future<void> _respond(bool approve) async {
    setState(() => _loading = true);
    // Capture repos before any await — widget may be disposed by the
    // Firestore stream update that fires when payment status changes.
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final memberRepo = ref.read(memberRepositoryProvider);
    final sessionCount = widget.payment.sessionCount;
    final ptId = widget.ptId;
    final memberId = widget.payment.memberId;
    try {
      if (approve) {
        await paymentRepo.updatePaymentStatus(
            widget.payment.id, PaymentStatus.completed, null);
        await memberRepo.updateRemainingSessions(
              ptId: ptId,
              memberId: memberId,
              delta: sessionCount,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$sessionCount seans üyeye yüklendi'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        await paymentRepo.updatePaymentStatus(
            widget.payment.id, PaymentStatus.failed, null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ödeme talebi reddedildi'),
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
    final p = widget.payment;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2,
                      color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_memberName(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        p.packageName,
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13),
                      ),
                      Text(
                        '${p.sessionCount} seans • ${p.amount.formattedCurrency}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Onay Bekliyor',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respond(true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          child: const Text('Onayla'),
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

class _PaymentTile extends ConsumerWidget {
  final PaymentModel payment;
  final String ptId;

  const _PaymentTile({required this.payment, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(
      ptMemberDetailProvider((ptId: ptId, memberId: payment.memberId)),
    );
    final memberName = memberAsync.valueOrNull?.name ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: payment.status == PaymentStatus.completed
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            payment.status == PaymentStatus.completed
                ? Icons.check_circle_outline
                : Icons.schedule,
            color: payment.status == PaymentStatus.completed
                ? Colors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          memberName.isNotEmpty ? memberName : payment.packageName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${payment.packageName} • ${payment.createdAt.formattedDate}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payment.amount.formattedCurrency,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: payment.status == PaymentStatus.completed
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            StatusBadge.payment(payment.status),
          ],
        ),
      ),
    );
  }
}
