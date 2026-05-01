import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/models/progress_model.dart';
import '../../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _ProgressContent(memberId: user.uid);
      },
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  final String memberId;

  const _ProgressContent({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressListProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlerleme Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.addProgress),
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (entries) {
          if (entries.isEmpty) {
            return AppEmpty(
              message: 'Henüz ilerleme kaydı yok',
              subMessage: 'Kilo ve ölçü bilgilerinizi kaydedin',
              icon: Icons.trending_up_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addProgress),
                icon: const Icon(Icons.add),
                label: const Text('Kayıt Ekle'),
              ),
            );
          }

          final weightEntries = entries
              .where((e) => e.weight != null)
              .toList()
              .reversed
              .toList();

          return CustomScrollView(
            slivers: [
              // Weight Chart
              if (weightEntries.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _WeightChart(entries: weightEntries),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ProgressCard(
                      progress: entries[i],
                      onDelete: () => ref
                          .read(progressRepositoryProvider)
                          .deleteProgress(entries[i].id),
                    ),
                    childCount: entries.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addProgress),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List entries;

  const _WeightChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), entries[i].weight as double),
    );

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kilo Grafiği',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()} kg',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
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
                    dotData: FlDotData(
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ProgressModel progress;
  final VoidCallback onDelete;

  const _ProgressCard({required this.progress, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  progress.date.formattedDate,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (progress.weight != null)
                  _MeasurementChip(
                    label: 'Kilo',
                    value: '${progress.weight} kg',
                    icon: Icons.monitor_weight_outlined,
                  ),
                if (progress.measurements?.waist != null)
                  _MeasurementChip(
                    label: 'Bel',
                    value: '${progress.measurements!.waist} cm',
                    icon: Icons.straighten,
                  ),
                if (progress.measurements?.chest != null)
                  _MeasurementChip(
                    label: 'Göğüs',
                    value: '${progress.measurements!.chest} cm',
                    icon: Icons.straighten,
                  ),
                if (progress.measurements?.hips != null)
                  _MeasurementChip(
                    label: 'Kalça',
                    value: '${progress.measurements!.hips} cm',
                    icon: Icons.straighten,
                  ),
              ],
            ),
            if (progress.photoUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: progress.photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const AppLoading(size: 24),
                  ),
                ),
              ),
            ],
            if (progress.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                progress.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MeasurementChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
