import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../domain/models/time_slot.dart';

class TimeSlotTile extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback? onTap;
  final bool compact;

  const TimeSlotTile({
    super.key,
    required this.slot,
    this.onTap,
    this.compact = false,
  });

  Color get _color {
    switch (slot.type) {
      case SlotType.available:
        return AppColors.slotAvailable;
      case SlotType.booked:
        return AppColors.slotBooked;
      case SlotType.myBooking:
        return AppColors.slotMyBooking;
      case SlotType.nativeCalendar:
        return AppColors.slotNativeCalendar;
      case SlotType.breakTime:
        return AppColors.slotBreak;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: slot.type == SlotType.breakTime ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          border: Border(left: BorderSide(color: _color, width: 4)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppDateUtils.formatTime(slot.start)} – ${AppDateUtils.formatTime(slot.end)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (slot.label != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    slot.label!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ] else if (slot.type == SlotType.available) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Boş',
                    style: TextStyle(fontSize: 13, color: AppColors.slotAvailable),
                  ),
                ] else if (slot.type == SlotType.breakTime) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Mola',
                    style: TextStyle(fontSize: 12, color: AppColors.slotBreak),
                  ),
                ],
              ],
            ),
            const Spacer(),
            if (slot.type == SlotType.available)
              Icon(Icons.add_circle_outline, color: AppColors.slotAvailable, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: slot.label != null
          ? Center(
              child: Text(
                slot.label!.split(' ').first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }
}
