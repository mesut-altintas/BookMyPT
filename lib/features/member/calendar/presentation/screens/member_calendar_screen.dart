import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../pt/calendar/domain/models/time_slot.dart';
import '../../../../pt/calendar/presentation/providers/pt_calendar_provider.dart';
import '../providers/member_calendar_provider.dart';
import '../widgets/member_slot_tile.dart';

class MemberCalendarScreen extends ConsumerWidget {
  const MemberCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(calendarViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final weekStart = ref.watch(currentWeekStartProvider);
    final trainerAsync = ref.watch(memberTrainerProvider);

    if (trainerAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final trainer = trainerAsync.valueOrNull;
    if (trainer == null) {
      return const Center(
        child: Text('PT takvimi yüklenemedi.'),
      );
    }

    if (!trainer.activeMembers.contains(
      ref.watch(
        memberCalendarDataSourceProvider.select((_) => null),
      ),
    )) {
      // Erişim kontrolü provider seviyesinde yapılıyor
    }

    return Column(
      children: [
        _MemberCalendarHeader(
          viewMode: viewMode,
          selectedDate: selectedDate,
          weekStart: weekStart,
        ),
        // Renk açıklaması
        _Legend(),
        Expanded(
          child: viewMode == CalendarViewMode.weekly
              ? _MemberWeeklyView(
                  weekStart: weekStart,
                  onDayTap: (day) {
                    ref.read(selectedDateProvider.notifier).state = day;
                    ref.read(calendarViewModeProvider.notifier).state =
                        CalendarViewMode.daily;
                  },
                )
              : _MemberDailyView(day: selectedDate),
        ),
      ],
    );
  }
}

class _MemberCalendarHeader extends ConsumerWidget {
  final CalendarViewMode viewMode;
  final DateTime selectedDate;
  final DateTime weekStart;

  const _MemberCalendarHeader({
    required this.viewMode,
    required this.selectedDate,
    required this.weekStart,
  });

  static const _months = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
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
                    ? '${weekStart.day} ${_months[weekStart.month - 1]} – ${weekEnd.day} ${_months[weekEnd.month - 1]}'
                    : AppDateUtils.formatDate(selectedDate),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _navigate(ref, 1),
          ),
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(
                  value: CalendarViewMode.weekly,
                  icon: Icon(Icons.view_week, size: 16)),
              ButtonSegment(
                  value: CalendarViewMode.daily,
                  icon: Icon(Icons.view_day, size: 16)),
            ],
            selected: {viewMode},
            onSelectionChanged: (s) =>
                ref.read(calendarViewModeProvider.notifier).state = s.first,
            style: const ButtonStyle(
                visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }

  void _navigate(WidgetRef ref, int dir) {
    final current = ref.read(selectedDateProvider);
    final days =
        ref.read(calendarViewModeProvider) == CalendarViewMode.weekly ? 7 : 1;
    ref.read(selectedDateProvider.notifier).state =
        current.add(Duration(days: days * dir));
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(AppColors.slotAvailable, 'Boş'),
            const SizedBox(width: 12),
            _LegendItem(AppColors.slotMyBooking, 'Benim'),
            const SizedBox(width: 12),
            _LegendItem(AppColors.slotBooked, 'Dolu'),
            const SizedBox(width: 12),
            _LegendItem(AppColors.slotBreak, 'Mola'),
          ],
        ),
      );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}

// ─── Günlük görünüm ─────────────────────────────────────────────────────────

class _MemberDailyView extends ConsumerWidget {
  final DateTime day;
  const _MemberDailyView({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(memberTimeSlotsForDayProvider(day));

    if (slots.isEmpty) {
      return const Center(child: Text('Bu gün için müsait slot yok.'));
    }

    return ListView.builder(
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final slot = slots[i];
        return MemberSlotTile(
          slot: slot,
          onTap: () => _handleTap(context, ref, slot),
        );
      },
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, TimeSlot slot) {
    if (slot.start.isBefore(DateTime.now())) return;
    if (slot.type == SlotType.available) {
      _showBookingDialog(context, ref, slot);
    } else if (slot.type == SlotType.myBooking) {
      _showCancelDialog(context, ref, slot);
    }
  }

  void _showBookingDialog(
      BuildContext context, WidgetRef ref, TimeSlot slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rezervasyon Yap'),
        content: Text(
          '${AppDateUtils.formatDate(slot.start)}\n'
          '${AppDateUtils.formatTime(slot.start)} – ${AppDateUtils.formatTime(slot.end)}\n\n'
          'Bu saati rezerve etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref
                  .read(bookingNotifierProvider.notifier)
                  .createBooking(slot.start, slot.end);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Rezervasyon oluşturuldu!'
                    : 'Rezervasyon başarısız. Saat dolu olabilir.'),
                backgroundColor: ok ? Colors.green : Colors.red,
              ));
            },
            child: const Text('Rezerve Et'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, TimeSlot slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İptal Talebi'),
        content: Text(
          '${AppDateUtils.formatDate(slot.start)} '
          '${AppDateUtils.formatTime(slot.start)} dersini iptal etmek istiyor musunuz?\n\n'
          'PT onaylayana kadar ders takvimde görünmeye devam eder.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              if (slot.bookingId == null) return;
              final ok = await ref
                  .read(bookingNotifierProvider.notifier)
                  .requestCancel(slot.bookingId!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'İptal talebiniz PT\'ye iletildi.'
                    : 'İptal talebi gönderilemedi.'),
                backgroundColor: ok ? Colors.orange : Colors.red,
              ));
            },
            child: const Text('İptal Talebi Gönder',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Haftalık görünüm ────────────────────────────────────────────────────────

class _MemberWeeklyView extends ConsumerWidget {
  final DateTime weekStart;
  final void Function(DateTime)? onDayTap;

  const _MemberWeeklyView({required this.weekStart, this.onDayTap});

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final today = DateTime.now();

    return Column(
      children: [
        // Gün başlıkları
        Container(
          color: Colors.white,
          child: Row(
            children: [
              const SizedBox(width: 44),
              ...days.asMap().entries.map((e) {
                final day = e.value;
                final isToday = AppDateUtils.isSameDay(day, today);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDayTap?.call(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isToday
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_dayNames[e.key],
                              style: TextStyle(
                                fontSize: 11,
                                color: isToday
                                    ? AppColors.primary
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 2),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: isToday
                                ? const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle)
                                : null,
                            child: Center(
                              child: Text('${day.day}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? Colors.white
                                        : Colors.black87,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 44, child: _TimeLabels(days: days, ref: ref)),
                ...days.map((day) => Expanded(
                      child: _MemberDayColumn(day: day),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeLabels extends StatelessWidget {
  final List<DateTime> days;
  final WidgetRef ref;
  const _TimeLabels({required this.days, required this.ref});

  @override
  Widget build(BuildContext context) {
    final slots = ref.watch(memberTimeSlotsForDayProvider(days.first));
    return Column(
      children: slots.map((s) => SizedBox(
            height: s.duration.inMinutes * 1.2,
            child: s.type != SlotType.breakTime
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      AppDateUtils.formatTime(s.start),
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                  )
                : null,
          )).toList(),
    );
  }
}

class _MemberDayColumn extends ConsumerWidget {
  final DateTime day;
  const _MemberDayColumn({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(memberTimeSlotsForDayProvider(day));
    return Column(
      children: slots.map((slot) => SizedBox(
            height: slot.duration.inMinutes * 1.2,
            child: MemberSlotTile(slot: slot, compact: true),
          )).toList(),
    );
  }
}
