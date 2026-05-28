/// Model for PT's working schedule.
///
/// [days] maps Dart weekday (1=Monday … 7=Sunday) to [DaySchedule].
class WorkSchedule {
  final Map<int, DaySchedule> days;

  const WorkSchedule({required this.days});

  factory WorkSchedule.defaults() {
    return WorkSchedule(
      days: {
        for (int i = 1; i <= 7; i++)
          i: DaySchedule(
            isActive: i <= 5, // Mon-Fri active by default
            startTime: '09:00',
            endTime: '18:00',
          ),
      },
    );
  }

  factory WorkSchedule.fromMap(Map<String, dynamic> map) {
    final days = <int, DaySchedule>{};
    for (int i = 1; i <= 7; i++) {
      final raw = map[i.toString()];
      if (raw is Map) {
        days[i] = DaySchedule.fromMap(Map<String, dynamic>.from(raw));
      }
    }
    return WorkSchedule(days: days);
  }

  Map<String, dynamic> toMap() => {
        for (final e in days.entries) e.key.toString(): e.value.toMap(),
      };

  DaySchedule? getDay(int weekday) => days[weekday];

  bool isWorkingDay(int weekday) => days[weekday]?.isActive ?? false;

  /// Returns a Turkish error string if the session falls outside work hours,
  /// null if it's valid. Returns null when no schedule is configured.
  String? validateSession(DateTime start, int durationMinutes) {
    if (days.isEmpty) return null;
    final day = days[start.weekday];
    if (day == null || !day.isActive) return 'PT bu gün çalışmıyor';

    final sessionEnd = start.add(Duration(minutes: durationMinutes));
    final workStart = _parseTime(day.startTime, start);
    final workEnd = _parseTime(day.endTime, start);

    if (start.isBefore(workStart) || sessionEnd.isAfter(workEnd)) {
      return 'PT çalışma saatleri: ${day.startTime} – ${day.endTime}';
    }

    if (day.hasBreak) {
      final bStart = _parseTime(day.breakStart!, start);
      final bEnd = _parseTime(day.breakEnd!, start);
      if (start.isBefore(bEnd) && sessionEnd.isAfter(bStart)) {
        return 'PT mola saatleri: ${day.breakStart} – ${day.breakEnd}';
      }
    }

    return null;
  }

  static DateTime _parseTime(String hhmm, DateTime date) {
    final p = hhmm.split(':');
    return DateTime(date.year, date.month, date.day,
        int.parse(p[0]), int.parse(p[1]));
  }
}

class DaySchedule {
  final bool isActive;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final String? breakStart;
  final String? breakEnd;

  const DaySchedule({
    required this.isActive,
    required this.startTime,
    required this.endTime,
    this.breakStart,
    this.breakEnd,
  });

  bool get hasBreak => breakStart != null && breakEnd != null;

  factory DaySchedule.fromMap(Map<String, dynamic> map) => DaySchedule(
        isActive: map['isActive'] as bool? ?? false,
        startTime: map['startTime'] as String? ?? '09:00',
        endTime: map['endTime'] as String? ?? '18:00',
        breakStart: map['breakStart'] as String?,
        breakEnd: map['breakEnd'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'isActive': isActive,
        'startTime': startTime,
        'endTime': endTime,
        if (breakStart != null) 'breakStart': breakStart,
        if (breakEnd != null) 'breakEnd': breakEnd,
      };

  DaySchedule copyWith({
    bool? isActive,
    String? startTime,
    String? endTime,
    String? breakStart,
    String? breakEnd,
    bool clearBreak = false,
  }) =>
      DaySchedule(
        isActive: isActive ?? this.isActive,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        breakStart: clearBreak ? null : (breakStart ?? this.breakStart),
        breakEnd: clearBreak ? null : (breakEnd ?? this.breakEnd),
      );
}
