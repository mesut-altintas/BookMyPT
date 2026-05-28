import 'package:flutter_test/flutter_test.dart';
import 'package:bookmypt/core/utils/duration_utils.dart';

void main() {
  group('formatDurationMinutes', () {
    test('30 → "30 dk"', () => expect(formatDurationMinutes(30), '30 dk'));
    test('45 → "45 dk"', () => expect(formatDurationMinutes(45), '45 dk'));
    test('59 → "59 dk"', () => expect(formatDurationMinutes(59), '59 dk'));
    test('60 → "1 sa"',  () => expect(formatDurationMinutes(60), '1 sa'));
    test('90 → "1 sa 30 dk"', () => expect(formatDurationMinutes(90), '1 sa 30 dk'));
    test('120 → "2 sa"',  () => expect(formatDurationMinutes(120), '2 sa'));
    test('75 → "1 sa 15 dk"', () => expect(formatDurationMinutes(75), '1 sa 15 dk'));
    test('150 → "2 sa 30 dk"', () => expect(formatDurationMinutes(150), '2 sa 30 dk'));
  });
}
