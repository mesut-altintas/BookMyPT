import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationSource { chat, calendar, members, earnings, payment }

NotificationSource? notificationSourceFromType(String? type) {
  switch (type) {
    case 'chat':     return NotificationSource.chat;
    case 'calendar': return NotificationSource.calendar;
    case 'members':  return NotificationSource.members;
    case 'earnings': return NotificationSource.earnings;
    case 'payment':  return NotificationSource.payment;
    default:         return null;
  }
}

class NotificationBadgeNotifier
    extends StateNotifier<Map<NotificationSource, int>> {
  NotificationBadgeNotifier()
      : super({
          NotificationSource.chat: 0,
          NotificationSource.calendar: 0,
          NotificationSource.members: 0,
          NotificationSource.earnings: 0,
          NotificationSource.payment: 0,
        });

  void increment(NotificationSource source) {
    state = {...state, source: (state[source] ?? 0) + 1};
  }

  void clear(NotificationSource source) {
    state = {...state, source: 0};
  }

  int count(NotificationSource source) => state[source] ?? 0;

  bool get hasAny => state.values.any((v) => v > 0);
}

final notificationBadgeProvider = StateNotifierProvider<
    NotificationBadgeNotifier, Map<NotificationSource, int>>(
  (ref) => NotificationBadgeNotifier(),
);
