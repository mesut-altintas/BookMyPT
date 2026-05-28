import 'package:flutter_test/flutter_test.dart';
import 'package:bookmypt/shared/models/member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('MemberProfile.fromMap', () {
    test('parses basic fields correctly', () {
      final data = {
        'name': 'Ali Yılmaz',
        'email': 'ali@example.com',
        'remainingSessions': 5,
        'isActive': true,
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      };

      final member = MemberProfile.fromMap('uid1', data);

      expect(member.memberId, 'uid1');
      expect(member.name, 'Ali Yılmaz');
      expect(member.email, 'ali@example.com');
      expect(member.remainingSessions, 5);
      expect(member.isActive, true);
    });

    test('defaults missing fields safely', () {
      final member = MemberProfile.fromMap('uid2', {
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(member.name, '');
      expect(member.email, '');
      expect(member.remainingSessions, 0);
      expect(member.isActive, true);
      expect(member.sessionDurationMinutes, isNull);
      expect(member.remainingSessionsByDuration, isEmpty);
    });

    // ── remainingSessionsByDuration ─────────────────────────────────────────

    test('parses remainingSessionsByDuration with string keys (Firestore format)', () {
      final data = {
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'remainingSessionsByDuration': {'45': 5, '60': 10},
      };

      final member = MemberProfile.fromMap('uid3', data);

      expect(member.remainingSessionsByDuration, {45: 5, 60: 10});
    });

    test('filters out zero-count durations', () {
      final data = {
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'remainingSessionsByDuration': {'45': 0, '60': 10},
      };

      final member = MemberProfile.fromMap('uid4', data);

      // _parseDurationMap skips zero values
      expect(member.remainingSessionsByDuration, {60: 10});
    });

    test('returns empty map when field is null', () {
      final data = {
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'remainingSessionsByDuration': null,
      };

      final member = MemberProfile.fromMap('uid5', data);
      expect(member.remainingSessionsByDuration, isEmpty);
    });

    test('returns empty map when field is absent', () {
      final member = MemberProfile.fromMap('uid6', {
        'joinedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(member.remainingSessionsByDuration, isEmpty);
    });
  });

  // ── availableDurations ────────────────────────────────────────────────────

  group('MemberProfile.availableDurations', () {
    MemberProfile _make(Map<int, int> byDuration) => MemberProfile(
          memberId: 'x',
          name: 'Test',
          email: 'test@test.com',
          joinedAt: DateTime(2024),
          remainingSessionsByDuration: byDuration,
        );

    test('returns empty list when no packages', () {
      expect(_make({}).availableDurations, isEmpty);
    });

    test('returns sorted durations with positive count', () {
      expect(_make({60: 10, 45: 5}).availableDurations, [45, 60]);
    });

    test('excludes durations with zero sessions', () {
      expect(_make({60: 0, 45: 5, 30: 2}).availableDurations, [30, 45]);
    });

    test('single duration returns single-element list', () {
      expect(_make({60: 1}).availableDurations, [60]);
    });

    test('sorts ascending', () {
      expect(_make({120: 3, 30: 5, 60: 10}).availableDurations, [30, 60, 120]);
    });
  });

  // ── toFirestore ───────────────────────────────────────────────────────────

  group('MemberProfile.toFirestore', () {
    test('serializes remainingSessionsByDuration with string keys', () {
      final member = MemberProfile(
        memberId: 'uid7',
        name: 'Test',
        email: 'test@test.com',
        joinedAt: DateTime(2024),
        remainingSessionsByDuration: {45: 5, 60: 10},
      );

      final map = member.toFirestore();
      final durationMap = map['remainingSessionsByDuration'] as Map;

      expect(durationMap['45'], 5);
      expect(durationMap['60'], 10);
    });

    test('omits remainingSessionsByDuration when empty', () {
      final member = MemberProfile(
        memberId: 'uid8',
        name: 'Test',
        email: 'test@test.com',
        joinedAt: DateTime(2024),
        remainingSessionsByDuration: {},
      );

      final map = member.toFirestore();
      expect(map.containsKey('remainingSessionsByDuration'), isFalse);
    });
  });
}
