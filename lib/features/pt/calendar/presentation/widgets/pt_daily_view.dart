import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../domain/models/time_slot.dart';
import '../providers/pt_calendar_provider.dart';
import 'time_slot_tile.dart';

class PtDailyView extends ConsumerWidget {
  final DateTime day;
  final void Function(TimeSlot slot)? onSlotTap;

  const PtDailyView({super.key, required this.day, this.onSlotTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(timeSlotsForDayProvider(day));

    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Bu gün için ayar yapılmamış.\nAyarlar ekranından çalışma saatlerinizi girin.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            AppDateUtils.formatDate(day),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: slots.length,
            itemBuilder: (context, i) => TimeSlotTile(
              slot: slots[i],
              onTap: () => onSlotTap?.call(slots[i]),
            ),
          ),
        ),
      ],
    );
  }
}
