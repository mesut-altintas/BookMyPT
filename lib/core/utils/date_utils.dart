import 'package:intl/intl.dart';

class AppDateUtils {
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy HH:mm', 'tr_TR');
  static final _dayFormat = DateFormat('EEEE', 'tr_TR');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String formatDay(DateTime dt) => _dayFormat.format(dt);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);

  static List<DateTime> weekDays(DateTime referenceDay) {
    final monday = referenceDay.subtract(
      Duration(days: referenceDay.weekday - 1),
    );
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }
}
