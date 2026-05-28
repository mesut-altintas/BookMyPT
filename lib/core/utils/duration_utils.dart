/// Formats a duration in minutes to a human-readable Turkish label.
/// Examples: 30 → "30 dk", 60 → "1 sa", 90 → "1 sa 30 dk"
String formatDurationMinutes(int minutes) {
  if (minutes < 60) return '$minutes dk';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h sa' : '$h sa $m dk';
}
