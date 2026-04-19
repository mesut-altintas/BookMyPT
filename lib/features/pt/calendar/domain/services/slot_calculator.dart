import '../../data/models/booking_model.dart';
import '../../data/models/calendar_block_model.dart';
import '../models/time_slot.dart';

class SlotCalculator {
  static List<TimeSlot> calculate({
    required DateTime day,
    required int workStartHour,
    required int workEndHour,
    required int slotDuration,
    required int breakDuration,
    required List<BookingModel> bookings,
    required List<CalendarBlockModel> blocks,
    List<int> blockedDays = const [],
  }) {
    // blockedDays: 1=Pzt … 7=Paz (Dart weekday)
    if (blockedDays.contains(day.weekday)) return [];

    final slots = <TimeSlot>[];
    final workEnd = DateTime(day.year, day.month, day.day, workEndHour);
    var cursor = DateTime(day.year, day.month, day.day, workStartHour);

    while (cursor.isBefore(workEnd)) {
      final slotEnd = cursor.add(Duration(minutes: slotDuration));
      if (slotEnd.isAfter(workEnd)) break;

      slots.add(_buildLessonSlot(cursor, slotEnd, bookings, blocks));
      cursor = slotEnd;

      if (breakDuration > 0) {
        final breakEnd = cursor.add(Duration(minutes: breakDuration));
        // Sadece arkasında en az bir ders daha sığıyorsa break ekle
        final nextSlotEnd = breakEnd.add(Duration(minutes: slotDuration));
        if (!nextSlotEnd.isAfter(workEnd)) {
          slots.add(TimeSlot(start: cursor, end: breakEnd, type: SlotType.breakTime));
          cursor = breakEnd;
        }
      }
    }

    return slots;
  }

  static TimeSlot _buildLessonSlot(
    DateTime start,
    DateTime end,
    List<BookingModel> bookings,
    List<CalendarBlockModel> blocks,
  ) {
    // Önce booking kontrolü
    final booking = bookings.where((b) =>
      b.status != BookingStatus.cancelled &&
      b.startTime.isBefore(end) &&
      b.endTime.isAfter(start),
    ).firstOrNull;

    if (booking != null) {
      return TimeSlot(
        start: start,
        end: end,
        type: SlotType.booked,
        label: booking.memberName,
        bookingId: booking.id,
        memberId: booking.memberId,
      );
    }

    // Sonra native calendar kontrolü
    final block = blocks.where((b) =>
      b.startTime.isBefore(end) &&
      b.endTime.isAfter(start),
    ).firstOrNull;

    if (block != null) {
      return TimeSlot(
        start: start,
        end: end,
        type: SlotType.nativeCalendar,
        label: block.title,
      );
    }

    return TimeSlot(start: start, end: end, type: SlotType.available);
  }
}
