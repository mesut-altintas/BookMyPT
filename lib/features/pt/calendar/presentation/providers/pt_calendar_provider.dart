import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/platform/native_calendar_bridge.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/calendar_block_model.dart';
import '../../domain/models/time_slot.dart';
import '../../domain/services/slot_calculator.dart';
import 'trainer_provider.dart';

enum CalendarViewMode { weekly, daily }

final calendarViewModeProvider =
    StateProvider<CalendarViewMode>((ref) => CalendarViewMode.weekly);

final selectedDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final nativeCalendarBridgeProvider =
    Provider<NativeCalendarBridge>((ref) => NativeCalendarBridge());

// Görüntülenen haftanın başı (Pazartesi)
final currentWeekStartProvider = Provider<DateTime>((ref) {
  final selected = ref.watch(selectedDateProvider);
  return AppDateUtils.weekDays(selected).first;
});

// Haftalık bookings stream
final weekBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final weekStart = ref.watch(currentWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return ref
      .watch(calendarDataSourceProvider)
      .bookingsStream(trainerId: user.id, start: weekStart, end: weekEnd);
});

// Haftalık calendar blocks stream
final weekCalendarBlocksProvider = StreamProvider<List<CalendarBlockModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final weekStart = ref.watch(currentWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return ref
      .watch(calendarDataSourceProvider)
      .calendarBlocksStream(trainerId: user.id, start: weekStart, end: weekEnd);
});

// Belirli bir gün için slot listesi
final timeSlotsForDayProvider =
    Provider.family<List<TimeSlot>, DateTime>((ref, day) {
  final trainer = ref.watch(trainerStreamProvider).valueOrNull;
  if (trainer == null) return [];

  final dayStart = AppDateUtils.startOfDay(day);
  final dayEnd = AppDateUtils.endOfDay(day);

  final allBookings = ref.watch(weekBookingsProvider).valueOrNull ?? [];
  final allBlocks = ref.watch(weekCalendarBlocksProvider).valueOrNull ?? [];

  final dayBookings = allBookings
      .where((b) => b.startTime.isAfter(dayStart) && b.startTime.isBefore(dayEnd))
      .toList();
  final dayBlocks = allBlocks
      .where((b) => b.startTime.isAfter(dayStart) && b.startTime.isBefore(dayEnd))
      .toList();

  return SlotCalculator.calculate(
    day: day,
    workStartHour: trainer.workStartHour,
    workEndHour: trainer.workEndHour,
    slotDuration: trainer.slotDuration,
    breakDuration: trainer.breakDuration,
    bookings: dayBookings,
    blocks: dayBlocks,
    blockedDays: trainer.blockedDays,
  );
});

// Native calendar senkronizasyonu
class NativeCalendarSyncNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  Timer? _timer;

  NativeCalendarSyncNotifier(this._ref) : super(const AsyncValue.data(null)) {
    _startPolling();
  }

  void _startPolling() {
    _sync();
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _sync(),
    );
  }

  Future<void> _sync() async {
    final trainer = _ref.read(trainerStreamProvider).valueOrNull;
    final user = _ref.read(authNotifierProvider).valueOrNull;
    if (trainer == null || user == null || trainer.selectedCalendarId == null) return;

    final bridge = _ref.read(nativeCalendarBridgeProvider);
    final weekStart = _ref.read(currentWeekStartProvider);
    final weekEnd = weekStart.add(const Duration(days: 14));

    final events = await bridge.getEvents(
      calendarId: trainer.selectedCalendarId!,
      start: weekStart,
      end: weekEnd,
    );

    final eventMaps = events
        .map((e) => {'id': e.id, 'title': e.title, 'start': e.start, 'end': e.end})
        .toList();

    await _ref.read(calendarDataSourceProvider).syncNativeBlocks(
      trainerId: user.id,
      start: weekStart,
      end: weekEnd,
      events: eventMaps,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final nativeCalendarSyncProvider =
    StateNotifierProvider<NativeCalendarSyncNotifier, AsyncValue<void>>(
  (ref) => NativeCalendarSyncNotifier(ref),
);
