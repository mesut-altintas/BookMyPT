enum SlotType { available, booked, myBooking, nativeCalendar, breakTime }

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final SlotType type;
  final String? label;
  final String? bookingId;
  final String? memberId;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.type,
    this.label,
    this.bookingId,
    this.memberId,
  });

  Duration get duration => end.difference(start);

  bool get isBookable => type == SlotType.available;
  bool get isMyBooking => type == SlotType.myBooking;
}
