import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';

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
          final completedPayments =
              payments.where((p) => p.status == PaymentStatus.completed).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Total Card
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
                                  label:
                                      '${payments.where((p) => p.status == PaymentStatus.pending).length} Bekleyen',
                                  icon: Icons.schedule,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Monthly chart
                      if (completedPayments.length > 1) ...[
                        const SizedBox(height: 20),
                        _MonthlyChart(payments: completedPayments),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'İşlem Geçmişi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (payments.isEmpty)
                SliverFillRemaining(
                  child: AppEmpty(
                    message: 'Henüz ödeme yok',
                    subMessage: 'Üyeleriniz paket satın aldığında burada görünür',
                    icon: Icons.account_balance_wallet_outlined,
                    action: ElevatedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.packageManagement),
                      icon: const Icon(Icons.add),
                      label: const Text('Paket Oluştur'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final p = payments[i];
                        return _PaymentTile(payment: p);
                      },
                      childCount: payments.length,
                    ),
                  ),
                ),
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

class _PaymentTile extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
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
          payment.packageName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(payment.createdAt.formattedDate),
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
