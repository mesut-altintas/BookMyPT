import 'package:flutter/services.dart';
import '../../features/pt/calendar/domain/models/native_calendar_model.dart';

class NativeCalendarBridge {
  static const _channel = MethodChannel('com.bookmypt/calendar');

  Future<List<NativeCalendarModel>> getCalendars() async {
    try {
      final result = await _channel.invokeMethod<List>('getCalendars');
      if (result == null) return [];
      return result
          .cast<Map<Object?, Object?>>()
          .map(NativeCalendarModel.fromMap)
          .toList();
    } on PlatformException catch (_) {
      return [];
    } on MissingPluginException catch (_) {
      return [];
    }
  }

  Future<List<NativeEventModel>> getEvents({
    required String calendarId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final result = await _channel.invokeMethod<List>('getEvents', {
        'calendarId': calendarId,
        'startMs': start.millisecondsSinceEpoch,
        'endMs': end.millisecondsSinceEpoch,
      });
      if (result == null) return [];
      return result
          .cast<Map<Object?, Object?>>()
          .map(NativeEventModel.fromMap)
          .toList();
    } on PlatformException catch (_) {
      return [];
    } on MissingPluginException catch (_) {
      return [];
    }
  }
}
