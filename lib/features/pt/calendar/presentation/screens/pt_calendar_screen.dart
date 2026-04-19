import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../domain/models/time_slot.dart';
import '../providers/pt_calendar_provider.dart';
import '../widgets/pt_daily_view.dart';
import '../widgets/pt_weekly_view.dart';

class PtCalendarScreen extends ConsumerWidget {
  const PtCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Native calendar senkronizasyonunu başlat
    ref.watch(nativeCalendarSyncProvider);

    final viewMode = ref.watch(calendarViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final weekStart = ref.watch(currentWeekStartProvider);

    return Column(
      children: [
        _CalendarHeader(
          viewMode: viewMode,
          selectedDate: selectedDate,
          weekStart: weekStart,
        ),
        Expanded(
          child: viewMode == CalendarViewMode.weekly
              ? PtWeeklyView(
                  weekStart: weekStart,
                  onDayTap: (day) {
                    ref.read(selectedDateProvider.notifier).state = day;
                    ref.read(calendarViewModeProvider.notifier).state =
                        CalendarViewMode.daily;
                  },
                  onSlotTap: (slot) => _onSlotTap(context, ref, slot),
                )
              : PtDailyView(
                  day: selectedDate,
                  onSlotTap: (slot) => _onSlotTap(context, ref, slot),
                ),
        ),
      ],
    );
  }

  void _onSlotTap(BuildContext context, WidgetRef ref, TimeSlot slot) {
    if (slot.type == SlotType.booked) {
      _showBookingDetails(context, slot);
    }
    // Available slotlar şimdilik bilgi göster (Faz 4'te üye yapacak rezervasyonu)
  }

  void _showBookingDetails(BuildContext context, TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.label ?? 'Rezervasyon',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppDateUtils.formatTime(slot.start)} – ${AppDateUtils.formatTime(slot.end)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success),
                const SizedBox(width: 8),
                const Text('Onaylandı'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends ConsumerWidget {
  final CalendarViewMode viewMode;
  final DateTime selectedDate;
  final DateTime weekStart;

  const _CalendarHeader({
    required this.viewMode,
    required this.selectedDate,
    required this.weekStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          // Geri / İleri ok
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _navigate(ref, -1),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref
                  .read(calendarViewModeProvider.notifier)
                  .state = CalendarViewMode.weekly,
              child: Text(
                viewMode == CalendarViewMode.weekly
                    ? '${weekStart.day} ${_monthShort(weekStart)} – ${weekEnd.day} ${_monthShort(weekEnd)}'
                    : AppDateUtils.formatDate(selectedDate),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _navigate(ref, 1),
          ),
          // Görünüm toggle
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(
                value: CalendarViewMode.weekly,
                icon: Icon(Icons.view_week, size: 16),
              ),
              ButtonSegment(
                value: CalendarViewMode.daily,
                icon: Icon(Icons.view_day, size: 16),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (s) =>
                ref.read(calendarViewModeProvider.notifier).state = s.first,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(WidgetRef ref, int direction) {
    final current = ref.read(selectedDateProvider);
    final days = ref.read(calendarViewModeProvider) == CalendarViewMode.weekly ? 7 : 1;
    ref.read(selectedDateProvider.notifier).state =
        current.add(Duration(days: days * direction));
  }

  String _monthShort(DateTime d) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[d.month - 1];
  }
}
