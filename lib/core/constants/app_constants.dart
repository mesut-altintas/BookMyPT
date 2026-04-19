class AppConstants {
  static const String appName = 'BookMyPT';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String trainersCollection = 'trainers';
  static const String membersCollection = 'members';
  static const String bookingsCollection = 'bookings';
  static const String calendarBlocksCollection = 'calendarBlocks';

  // Access code
  static const int accessCodeLength = 6;

  // Calendar polling interval (minutes)
  static const int calendarPollIntervalMinutes = 5;

  // Default slot durations (minutes)
  static const List<int> slotDurationOptions = [30, 45, 60, 90];
  static const List<int> breakDurationOptions = [0, 10, 15, 20];
  static const int defaultSlotDuration = 60;
  static const int defaultBreakDuration = 15;

  // Default working hours
  static const int defaultWorkStartHour = 9;
  static const int defaultWorkEndHour = 20;
}
