import 'package:flutter_test/flutter_test.dart';
import 'package:bookmypt/shared/models/work_schedule_model.dart';

// Helper: builds a DateTime for a given weekday and time on a fixed week.
// Monday 2024-01-01 is weekday 1.
DateTime _dt(int weekday, int hour, int minute) {
  // 2024-01-01 is a Monday (weekday 1)
  final monday = DateTime(2024, 1, 1);
  final offset = weekday - 1; // 0 = Mon, 6 = Sun
  return DateTime(monday.year, monday.month, monday.day + offset, hour, minute);
}

void main() {
  // ── WorkSchedule.defaults ─────────────────────────────────────────────────

  group('WorkSchedule.defaults', () {
    late WorkSchedule ws;
    setUpAll(() => ws = WorkSchedule.defaults());

    test('contains all 7 days', () {
      expect(ws.days.length, 7);
    });

    test('Mon-Fri are active', () {
      for (int i = 1; i <= 5; i++) {
        expect(ws.days[i]?.isActive, isTrue,
            reason: 'Weekday $i should be active');
      }
    });

    test('Sat-Sun are inactive', () {
      expect(ws.days[6]?.isActive, isFalse, reason: 'Saturday inactive');
      expect(ws.days[7]?.isActive, isFalse, reason: 'Sunday inactive');
    });

    test('default hours are 09:00 – 18:00', () {
      expect(ws.days[1]?.startTime, '09:00');
      expect(ws.days[1]?.endTime, '18:00');
    });
  });

  // ── WorkSchedule.isWorkingDay ─────────────────────────────────────────────

  group('WorkSchedule.isWorkingDay', () {
    final ws = WorkSchedule(days: {
      1: DaySchedule(isActive: true, startTime: '09:00', endTime: '18:00'),
      2: DaySchedule(isActive: false, startTime: '09:00', endTime: '18:00'),
    });

    test('returns true for active day', () {
      expect(ws.isWorkingDay(1), isTrue);
    });

    test('returns false for inactive day', () {
      expect(ws.isWorkingDay(2), isFalse);
    });

    test('returns false for undefined day', () {
      expect(ws.isWorkingDay(7), isFalse);
    });
  });

  // ── WorkSchedule.validateSession ─────────────────────────────────────────

  group('WorkSchedule.validateSession — no schedule', () {
    test('returns null when days is empty (no restrictions)', () {
      final ws = WorkSchedule(days: {});
      expect(ws.validateSession(_dt(1, 10, 0), 60), isNull);
    });
  });

  group('WorkSchedule.validateSession — valid slots', () {
    final ws = WorkSchedule(days: {
      1: DaySchedule(isActive: true, startTime: '09:00', endTime: '18:00'),
    });

    test('session within hours → no error', () {
      expect(ws.validateSession(_dt(1, 10, 0), 60), isNull);
    });

    test('session starting exactly at workStart → no error', () {
      expect(ws.validateSession(_dt(1, 9, 0), 60), isNull);
    });

    test('session ending exactly at workEnd → no error', () {
      expect(ws.validateSession(_dt(1, 17, 0), 60), isNull);
    });
  });

  group('WorkSchedule.validateSession — inactive day', () {
    final ws = WorkSchedule(days: {
      1: DaySchedule(isActive: true, startTime: '09:00', endTime: '18:00'),
      6: DaySchedule(isActive: false, startTime: '09:00', endTime: '18:00'),
    });

    test('inactive weekday → error', () {
      final result = ws.validateSession(_dt(6, 10, 0), 60);
      expect(result, isNotNull);
      expect(result, contains('çalışmıyor'));
    });

    test('undefined weekday → error', () {
      final result = ws.validateSession(_dt(7, 10, 0), 60);
      expect(result, isNotNull);
    });
  });

  group('WorkSchedule.validateSession — outside hours', () {
    final ws = WorkSchedule(days: {
      1: DaySchedule(isActive: true, startTime: '09:00', endTime: '18:00'),
    });

    test('session starts before work hours → error', () {
      final result = ws.validateSession(_dt(1, 8, 0), 60);
      expect(result, isNotNull);
      expect(result, contains('09:00'));
    });

    test('session ends after work hours → error', () {
      final result = ws.validateSession(_dt(1, 17, 30), 60); // ends at 18:30
      expect(result, isNotNull);
      expect(result, contains('18:00'));
    });

    test('session entirely after work hours → error', () {
      final result = ws.validateSession(_dt(1, 19, 0), 60);
      expect(result, isNotNull);
    });
  });

  group('WorkSchedule.validateSession — break time', () {
    final ws = WorkSchedule(days: {
      1: DaySchedule(
        isActive: true,
        startTime: '09:00',
        endTime: '18:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      ),
    });

    test('session before break → no error', () {
      expect(ws.validateSession(_dt(1, 10, 0), 60), isNull);
    });

    test('session after break → no error', () {
      expect(ws.validateSession(_dt(1, 14, 0), 60), isNull);
    });

    test('session starts exactly at breakEnd → no error', () {
      expect(ws.validateSession(_dt(1, 13, 0), 60), isNull);
    });

    test('session overlaps break start → error', () {
      final result = ws.validateSession(_dt(1, 11, 30), 60); // 11:30–12:30 overlaps 12:00–13:00
      expect(result, isNotNull);
      expect(result, contains('12:00'));
    });

    test('session inside break → error', () {
      final result = ws.validateSession(_dt(1, 12, 0), 30);
      expect(result, isNotNull);
    });

    test('session overlaps break end → error', () {
      final result = ws.validateSession(_dt(1, 12, 30), 60); // 12:30–13:30 overlaps 12:00–13:00
      expect(result, isNotNull);
    });
  });

  // ── WorkSchedule fromMap / toMap round-trip ───────────────────────────────

  group('WorkSchedule fromMap / toMap', () {
    test('round-trips basic schedule', () {
      final original = WorkSchedule(days: {
        1: DaySchedule(isActive: true, startTime: '08:00', endTime: '17:00'),
        6: DaySchedule(isActive: false, startTime: '09:00', endTime: '18:00'),
      });

      final map = original.toMap();
      final restored = WorkSchedule.fromMap(Map<String, dynamic>.from(map));

      expect(restored.days[1]?.isActive, isTrue);
      expect(restored.days[1]?.startTime, '08:00');
      expect(restored.days[1]?.endTime, '17:00');
      expect(restored.days[6]?.isActive, isFalse);
    });

    test('round-trips break time', () {
      final original = WorkSchedule(days: {
        1: DaySchedule(
          isActive: true,
          startTime: '09:00',
          endTime: '18:00',
          breakStart: '12:00',
          breakEnd: '13:00',
        ),
      });

      final restored =
          WorkSchedule.fromMap(Map<String, dynamic>.from(original.toMap()));

      expect(restored.days[1]?.breakStart, '12:00');
      expect(restored.days[1]?.breakEnd, '13:00');
      expect(restored.days[1]?.hasBreak, isTrue);
    });

    test('day without break has no break fields', () {
      final ws = WorkSchedule(days: {
        1: DaySchedule(isActive: true, startTime: '09:00', endTime: '18:00'),
      });

      final map = ws.toMap();
      final dayMap = map['1'] as Map<String, dynamic>;

      expect(dayMap.containsKey('breakStart'), isFalse);
      expect(dayMap.containsKey('breakEnd'), isFalse);
    });
  });

  // ── DaySchedule.hasBreak ──────────────────────────────────────────────────

  group('DaySchedule.hasBreak', () {
    test('true when both breakStart and breakEnd are set', () {
      final day = DaySchedule(
        isActive: true,
        startTime: '09:00',
        endTime: '18:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );
      expect(day.hasBreak, isTrue);
    });

    test('false when no break', () {
      final day = DaySchedule(
          isActive: true, startTime: '09:00', endTime: '18:00');
      expect(day.hasBreak, isFalse);
    });

    test('false when only one break field is set', () {
      final day = DaySchedule(
        isActive: true,
        startTime: '09:00',
        endTime: '18:00',
        breakStart: '12:00',
      );
      expect(day.hasBreak, isFalse);
    });
  });
}
