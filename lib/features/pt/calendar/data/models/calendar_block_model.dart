import 'package:cloud_firestore/cloud_firestore.dart';

enum CalendarBlockSource { nativeCalendar, booking, manual }

class CalendarBlockModel {
  final String id;
  final String trainerId;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarBlockSource source;
  final String? externalEventId;
  final String? title;

  const CalendarBlockModel({
    required this.id,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.externalEventId,
    this.title,
  });

  factory CalendarBlockModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarBlockModel(
      id: doc.id,
      trainerId: data['trainerId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      source: _parseSource(data['source']),
      externalEventId: data['externalEventId'],
      title: data['title'],
    );
  }

  static CalendarBlockSource _parseSource(String? s) {
    switch (s) {
      case 'booking':
        return CalendarBlockSource.booking;
      case 'manual':
        return CalendarBlockSource.manual;
      default:
        return CalendarBlockSource.nativeCalendar;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'trainerId': trainerId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'source': _sourceString(source),
        if (externalEventId != null) 'externalEventId': externalEventId,
        if (title != null) 'title': title,
      };

  static String _sourceString(CalendarBlockSource s) {
    switch (s) {
      case CalendarBlockSource.booking:
        return 'booking';
      case CalendarBlockSource.manual:
        return 'manual';
      case CalendarBlockSource.nativeCalendar:
        return 'native_calendar';
    }
  }
}
