import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../pt/calendar/data/models/booking_model.dart';
import '../../../calendar/presentation/providers/member_calendar_provider.dart'
    show bookingNotifierProvider, currentMemberProvider, myBookingsProvider;

class MyLessonsScreen extends ConsumerWidget {
  const MyLessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (bookings) {
        final now = DateTime.now();
        final upcoming = bookings
            .where((b) =>
                b.startTime.isAfter(now) &&
                (b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.pendingCancel))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        final past = bookings
            .where((b) =>
                b.startTime.isBefore(now) &&
                b.status != BookingStatus.cancelled)
            .toList();

        final cancelled = bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();

        return Column(
          children: [
            const _PackageSummary(),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Yaklaşan'),
                        Tab(text: 'Geçmiş'),
                        Tab(text: 'İptal'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _LessonList(
                            bookings: upcoming,
                            emptyText: 'Yaklaşan ders yok.',
                            showCancelButton: true,
                          ),
                          _LessonList(
                            bookings: past,
                            emptyText: 'Geçmiş ders yok.',
                          ),
                          _LessonList(
                            bookings: cancelled,
                            emptyText: 'İptal edilen ders yok.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackageSummary extends ConsumerWidget {
  const _PackageSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(currentMemberProvider);
    final member = memberAsync.valueOrNull;
    final pkg = member?.package;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: pkg == null
          ? const Center(
              child: SizedBox(
                height: 40,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem('Toplam', '${pkg.total}', Icons.fitness_center),
                _StatItem('Kullanılan', '${pkg.used}', Icons.check_circle_outline),
                _StatItem('Kalan', '${pkg.remaining}', Icons.hourglass_bottom),
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
}

class _LessonList extends ConsumerWidget {
  final List<BookingModel> bookings;
  final String emptyText;
  final bool showCancelButton;

  const _LessonList({
    required this.bookings,
    required this.emptyText,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyText, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookings.length,
      itemBuilder: (_, i) =>
          _LessonCard(booking: bookings[i], showCancelButton: showCancelButton),
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final BookingModel booking;
  final bool showCancelButton;
  const _LessonCard(
      {required this.booking, required this.showCancelButton});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pendingCancel:
        return AppColors.warning;
      case BookingStatus.cancelled:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Onaylı';
      case BookingStatus.pendingCancel:
        return 'İptal Bekleniyor';
      case BookingStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${booking.startTime.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                        fontSize: 18),
                  ),
                  Text(
                    _monthShort(booking.startTime.month),
                    style: TextStyle(fontSize: 10, color: _statusColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatDay(booking.startTime),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '${AppDateUtils.formatTime(booking.startTime)} – ${AppDateUtils.formatTime(booking.endTime)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          fontSize: 10,
                          color: _statusColor,
                          fontWeight: FontWeight.bold)),
                ),
                if (showCancelButton &&
                    booking.status == BookingStatus.confirmed) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _confirmCancel(context, ref),
                    child: const Text(
                      'İptal Talebi',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İptal Talebi'),
        content: Text(
          '${AppDateUtils.formatDate(booking.startTime)} '
          '${AppDateUtils.formatTime(booking.startTime)} dersini iptal etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(bookingNotifierProvider.notifier)
                  .requestCancel(booking.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İptal talebiniz PT\'ye iletildi.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Gönder',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[m - 1];
  }
}
