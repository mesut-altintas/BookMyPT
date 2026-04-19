import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../pt/calendar/domain/models/time_slot.dart';

class MemberSlotTile extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback? onTap;
  final bool compact;

  const MemberSlotTile({
    super.key,
    required this.slot,
    this.onTap,
    this.compact = false,
  });

  Color get _color {
    switch (slot.type) {
      case SlotType.available:
        return AppColors.slotAvailable;
      case SlotType.myBooking:
        return AppColors.slotMyBooking;
      case SlotType.booked:
        return AppColors.slotBooked;
      case SlotType.nativeCalendar:
        return AppColors.slotNativeCalendar;
      case SlotType.breakTime:
        return AppColors.slotBreak;
    }
  }

  bool get _tappable =>
      slot.type == SlotType.available || slot.type == SlotType.myBooking;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: _tappable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: _tappable ? 0.15 : 0.08),
          border: Border(left: BorderSide(color: _color, width: 4)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                const SizedBox(height: 2),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _tappable ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (slot.type == SlotType.available)
              Icon(Icons.add_circle_outline, color: AppColors.slotAvailable),
            if (slot.type == SlotType.myBooking)
              const Icon(Icons.event_available, color: AppColors.slotMyBooking),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: slot.type == SlotType.breakTime ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  String get _label {
    switch (slot.type) {
      case SlotType.available:
        return 'Rezerve Et';
      case SlotType.myBooking:
        return 'Rezervasyonum';
      case SlotType.booked:
        return 'Dolu';
      case SlotType.nativeCalendar:
        return slot.label ?? 'Meşgul';
      case SlotType.breakTime:
        return 'Mola';
    }
  }
}
