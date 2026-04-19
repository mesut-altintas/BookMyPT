import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../calendar/data/models/booking_model.dart';
import '../../../members/data/models/member_model.dart';
import '../../../members/presentation/providers/members_provider.dart';

class PtReportsScreen extends ConsumerStatefulWidget {
  const PtReportsScreen({super.key});

  @override
  ConsumerState<PtReportsScreen> createState() => _PtReportsScreenState();
}

class _PtReportsScreenState extends ConsumerState<PtReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zaman Bazlı'),
            Tab(text: 'Üye Bazlı'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _TimeBasedReport(),
              _MemberBasedReport(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Zaman bazlı rapor ───────────────────────────────────────────────────────

class _TimeBasedReport extends ConsumerStatefulWidget {
  const _TimeBasedReport();

  @override
  ConsumerState<_TimeBasedReport> createState() => _TimeBasedReportState();
}

class _TimeBasedReportState extends ConsumerState<_TimeBasedReport> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  List<BookingModel>? _bookings;
  bool _loading = false;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _range,
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _bookings = null;
      });
      await _load();
    }
  }

  Future<void> _load() async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    setState(() => _loading = true);

    final snap = await FirebaseFirestore.instance
        .collection(AppConstants.bookingsCollection)
        .where('trainerId', isEqualTo: user.id)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_range.start))
        .where('startTime',
            isLessThanOrEqualTo: Timestamp.fromDate(
                _range.end.add(const Duration(days: 1))))
        .get();

    setState(() {
      _bookings = snap.docs.map(BookingModel.fromFirestore).toList();
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _bookings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih aralığı seç
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              '${AppDateUtils.formatDate(_range.start)} – ${AppDateUtils.formatDate(_range.end)}',
            ),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (bookings != null) ...[
            _StatsRow(bookings: bookings),
            const SizedBox(height: 24),
            if (bookings.isNotEmpty) ...[
              Text('Günlük Dersler',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 200, child: _BookingBarChart(bookings: bookings, range: _range)),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<BookingModel> bookings;
  const _StatsRow({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final total = bookings.length;
    final confirmed = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pendingCancel).length;

    return Row(
      children: [
        _StatCard('Toplam', total, AppColors.primary),
        const SizedBox(width: 8),
        _StatCard('Onaylı', confirmed, AppColors.success),
        const SizedBox(width: 8),
        _StatCard('İptal', cancelled, Colors.grey),
        const SizedBox(width: 8),
        _StatCard('Bekliyor', pending, AppColors.warning),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
}

class _BookingBarChart extends StatelessWidget {
  final List<BookingModel> bookings;
  final DateTimeRange range;

  const _BookingBarChart({required this.bookings, required this.range});

  @override
  Widget build(BuildContext context) {
    // Günlere göre grupla (max 14 gün göster)
    final days = range.duration.inDays.clamp(1, 14);
    final start = range.end.subtract(Duration(days: days - 1));

    final Map<int, int> countByDay = {};
    for (var i = 0; i < days; i++) {
      countByDay[i] = 0;
    }

    for (final b in bookings) {
      if (b.status == BookingStatus.cancelled) continue;
      final diff = b.startTime.difference(start).inDays;
      if (diff >= 0 && diff < days) {
        countByDay[diff] = (countByDay[diff] ?? 0) + 1;
      }
    }

    final maxY = countByDay.values.fold(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY + 1,
        barGroups: List.generate(days, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (countByDay[i] ?? 0).toDouble(),
                color: AppColors.primary,
                width: days > 7 ? 8 : 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (v, _) {
                final day = start.add(Duration(days: v.toInt()));
                return Text(
                  '${day.day}',
                  style: const TextStyle(fontSize: 9),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ─── Üye bazlı rapor ─────────────────────────────────────────────────────────

class _MemberBasedReport extends ConsumerStatefulWidget {
  const _MemberBasedReport();

  @override
  ConsumerState<_MemberBasedReport> createState() => _MemberBasedReportState();
}

class _MemberBasedReportState extends ConsumerState<_MemberBasedReport> {
  MemberModel? _selected;
  List<BookingModel>? _bookings;

  Future<void> _loadBookings(MemberModel member) async {
    final snap = await FirebaseFirestore.instance
        .collection(AppConstants.bookingsCollection)
        .where('memberId', isEqualTo: member.id)
        .orderBy('startTime', descending: true)
        .get();

    setState(() {
      _bookings = snap.docs.map(BookingModel.fromFirestore).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersStreamProvider).valueOrNull ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<MemberModel>(
            value: _selected,
            decoration: const InputDecoration(
              labelText: 'Üye Seç',
              prefixIcon: Icon(Icons.person),
            ),
            items: members
                .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                .toList(),
            onChanged: (m) {
              if (m == null) return;
              setState(() {
                _selected = m;
                _bookings = null;
              });
              _loadBookings(m);
            },
          ),
          const SizedBox(height: 20),
          if (_selected != null) ...[
            _MemberPackageSummary(member: _selected!),
            const SizedBox(height: 16),
          ],
          if (_bookings != null) ...[
            Text('Ders Geçmişi (${_bookings!.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._bookings!.map((b) => _MemberLessonTile(booking: b)),
          ],
        ],
      ),
    );
  }
}

class _MemberPackageSummary extends StatelessWidget {
  final MemberModel member;
  const _MemberPackageSummary({required this.member});

  @override
  Widget build(BuildContext context) {
    final pkg = member.package;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PkgStat('Toplam', pkg.total, AppColors.primary),
              _PkgStat('Kullanılan', pkg.used, Colors.orange),
              _PkgStat('Kalan', pkg.remaining, AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _PkgStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _PkgStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}

class _MemberLessonTile extends StatelessWidget {
  final BookingModel booking;
  const _MemberLessonTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isPast = booking.startTime.isBefore(DateTime.now());
    final statusColor = booking.status == BookingStatus.confirmed
        ? (isPast ? Colors.grey : AppColors.success)
        : booking.status == BookingStatus.cancelled
            ? Colors.red
            : AppColors.warning;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        leading: Icon(
          isPast ? Icons.check_circle : Icons.schedule,
          color: statusColor,
        ),
        title: Text(AppDateUtils.formatDateTime(booking.startTime)),
        trailing: Text(
          booking.status == BookingStatus.confirmed
              ? (isPast ? 'Tamamlandı' : 'Yaklaşan')
              : booking.status == BookingStatus.cancelled
                  ? 'İptal'
                  : 'İptal Bekliyor',
          style: TextStyle(fontSize: 11, color: statusColor),
        ),
      ),
    );
  }
}
