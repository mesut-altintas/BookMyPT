import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../domain/models/time_slot.dart';
import '../providers/pt_calendar_provider.dart';
import 'time_slot_tile.dart';

class PtWeeklyView extends ConsumerWidget {
  final DateTime weekStart;
  final void Function(DateTime day)? onDayTap;
  final void Function(TimeSlot slot)? onSlotTap;

  const PtWeeklyView({
    super.key,
    required this.weekStart,
    this.onDayTap,
    this.onSlotTap,
  });

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
                            color: isToday ? AppColors.primary : Colors.grey.shade200,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayNames[e.key],
                            style: TextStyle(
                              fontSize: 11,
                              color: isToday ? AppColors.primary : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: isToday
                                ? const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.white : Colors.black87,
                                ),
                              ),
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
        // Slot grid
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saat kolonu
                SizedBox(
                  width: 44,
                  child: _TimeColumn(days: days, ref: ref),
                ),
                // Gün kolonları
                ...days.map(
                  (day) => Expanded(
                    child: _DayColumn(
                      day: day,
                      onSlotTap: onSlotTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final List<DateTime> days;
  final WidgetRef ref;

  const _TimeColumn({required this.days, required this.ref});

  @override
  Widget build(BuildContext context) {
    // İlk günün slotlarından saatleri al
    final slots = ref.watch(timeSlotsForDayProvider(days.first));
    if (slots.isEmpty) return const SizedBox.shrink();

    return Column(
      children: slots.map((slot) {
        final h = _slotHeight(slot);
        return SizedBox(
          height: h,
          child: slot.type != SlotType.breakTime
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    AppDateUtils.formatTime(slot.start),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                )
              : null,
        );
      }).toList(),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  final DateTime day;
  final void Function(TimeSlot slot)? onSlotTap;

  const _DayColumn({required this.day, this.onSlotTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(timeSlotsForDayProvider(day));
    if (slots.isEmpty) return const SizedBox.shrink();

    return Column(
      children: slots.map((slot) {
        final h = _slotHeight(slot);
        return SizedBox(
          height: h,
          child: GestureDetector(
            onTap: slot.type == SlotType.breakTime ? null : () => onSlotTap?.call(slot),
            child: TimeSlotTile(slot: slot, compact: true),
          ),
        );
      }).toList(),
    );
  }
}

double _slotHeight(TimeSlot slot) => slot.duration.inMinutes * 1.2;
