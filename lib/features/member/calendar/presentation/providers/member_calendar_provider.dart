import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../pt/calendar/data/models/booking_model.dart';
import '../../../../pt/calendar/data/models/calendar_block_model.dart';
import '../../../../pt/calendar/domain/models/time_slot.dart';
import '../../../../pt/calendar/domain/services/slot_calculator.dart';
import '../../../../pt/calendar/presentation/providers/pt_calendar_provider.dart';
import '../../../../pt/members/data/models/member_model.dart';
import '../../../../pt/members/data/models/trainer_model.dart';
import '../../data/datasources/member_calendar_datasource.dart';

final memberCalendarDataSourceProvider =
    Provider<MemberCalendarDataSource>((ref) {
  return MemberCalendarDataSource(FirebaseFirestore.instance);
});

// Üyenin bağlı olduğu trainer'ın verisi
final memberTrainerProvider = StreamProvider<TrainerModel?>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final trainerId = user?.trainerId;
  if (trainerId == null) return Stream.value(null);
  return ref
      .watch(memberCalendarDataSourceProvider)
      .trainerStream(trainerId);
});

// Haftalık bookings (trainer'ın tüm bookingleri)
final memberWeekBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final trainerId = user?.trainerId;
  if (trainerId == null) return Stream.value([]);
  final weekStart = ref.watch(currentWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return ref.watch(memberCalendarDataSourceProvider).bookingsStream(
        trainerId: trainerId,
        start: weekStart,
        end: weekEnd,
      );
});

// Haftalık calendar blocks
final memberWeekBlocksProvider =
    StreamProvider<List<CalendarBlockModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final trainerId = user?.trainerId;
  if (trainerId == null) return Stream.value([]);
  final weekStart = ref.watch(currentWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return ref.watch(memberCalendarDataSourceProvider).calendarBlocksStream(
        trainerId: trainerId,
        start: weekStart,
        end: weekEnd,
      );
});

// Günlük slot listesi (üye perspektifinden — kendi bookingleri mavi)
final memberTimeSlotsForDayProvider =
    Provider.family<List<TimeSlot>, DateTime>((ref, day) {
  final trainer = ref.watch(memberTrainerProvider).valueOrNull;
  if (trainer == null) return [];

  final user = ref.watch(authNotifierProvider).valueOrNull;
  final memberId = user?.memberId ?? '';

  final dayStart = AppDateUtils.startOfDay(day);
  final dayEnd = AppDateUtils.endOfDay(day);

  final allBookings =
      ref.watch(memberWeekBookingsProvider).valueOrNull ?? [];
  final allBlocks = ref.watch(memberWeekBlocksProvider).valueOrNull ?? [];

  final dayBookings = allBookings
      .where((b) =>
          b.startTime.isAfter(dayStart) && b.startTime.isBefore(dayEnd))
      .toList();
  final dayBlocks = allBlocks
      .where((b) =>
          b.startTime.isAfter(dayStart) && b.startTime.isBefore(dayEnd))
      .toList();

  final slots = SlotCalculator.calculate(
    day: day,
    workStartHour: trainer.workStartHour,
    workEndHour: trainer.workEndHour,
    slotDuration: trainer.slotDuration,
    breakDuration: trainer.breakDuration,
    bookings: dayBookings,
    blocks: dayBlocks,
    blockedDays: trainer.blockedDays,
  );

  // Kendi bookinglerini myBooking olarak işaretle
  return slots.map((slot) {
    if (slot.type == SlotType.booked && slot.memberId == memberId) {
      return TimeSlot(
        start: slot.start,
        end: slot.end,
        type: SlotType.myBooking,
        label: slot.label,
        bookingId: slot.bookingId,
        memberId: slot.memberId,
      );
    }
    return slot;
  }).toList();
});

// Üyenin kendi MemberModel'i (paket bilgisi için)
final currentMemberProvider = StreamProvider<MemberModel?>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final memberId = user?.memberId;
  if (memberId == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.membersCollection)
      .doc(memberId)
      .snapshots()
      .map((doc) => doc.exists ? MemberModel.fromFirestore(doc) : null);
});

// Üyenin tüm booking'leri
final myBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final memberId = user?.memberId;
  if (memberId == null) return Stream.value([]);
  return ref
      .watch(memberCalendarDataSourceProvider)
      .myBookingsStream(memberId);
});

// Rezervasyon işlemleri
class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final MemberCalendarDataSource _ds;
  final String _trainerId;
  final String _memberId;
  final String _memberName;

  BookingNotifier(this._ds, this._trainerId, this._memberId, this._memberName)
      : super(const AsyncValue.data(null));

  Future<bool> createBooking(DateTime start, DateTime end) async {
    if (_trainerId.isEmpty || _memberId.isEmpty) return false;
    state = const AsyncValue.loading();
    try {
      await _ds.createBooking(
        trainerId: _trainerId,
        memberId: _memberId,
        memberName: _memberName,
        startTime: start,
        endTime: end,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> requestCancel(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.requestCancel(bookingId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final ds = ref.watch(memberCalendarDataSourceProvider);
  return BookingNotifier(
    ds,
    user?.trainerId ?? '',
    user?.memberId ?? '',
    user?.name ?? '',
  );
});
