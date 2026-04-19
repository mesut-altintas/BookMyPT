class NativeCalendarModel {
  final String id;
  final String name;
  final int color;

  const NativeCalendarModel({
    required this.id,
    required this.name,
    required this.color,
  });

  factory NativeCalendarModel.fromMap(Map<Object?, Object?> map) =>
      NativeCalendarModel(
        id: map['id'] as String,
        name: map['name'] as String,
        color: (map['color'] as int?) ?? 0xFF2196F3,
      );
}

class NativeEventModel {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  const NativeEventModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  factory NativeEventModel.fromMap(Map<Object?, Object?> map) =>
      NativeEventModel(
        id: map['id'] as String,
        title: map['title'] as String? ?? 'Etkinlik',
        start: DateTime.fromMillisecondsSinceEpoch(map['startMs'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(map['endMs'] as int),
      );
}
