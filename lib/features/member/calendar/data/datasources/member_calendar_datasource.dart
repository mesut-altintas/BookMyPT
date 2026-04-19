import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../pt/calendar/data/models/booking_model.dart';
import '../../../../pt/calendar/data/models/calendar_block_model.dart';
import '../../../../pt/members/data/models/trainer_model.dart';

class MemberCalendarDataSource {
  final FirebaseFirestore _db;

  MemberCalendarDataSource(this._db);

  Stream<TrainerModel?> trainerStream(String trainerId) {
    return _db
        .collection(AppConstants.trainersCollection)
        .doc(trainerId)
        .snapshots()
        .map((doc) => doc.exists ? TrainerModel.fromFirestore(doc) : null);
  }

  Stream<List<BookingModel>> bookingsStream({
    required String trainerId,
    required DateTime start,
    required DateTime end,
  }) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTime', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(BookingModel.fromFirestore).toList());
  }

  Stream<List<CalendarBlockModel>> calendarBlocksStream({
    required String trainerId,
    required DateTime start,
    required DateTime end,
  }) {
    return _db
        .collection(AppConstants.calendarBlocksCollection)
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTime', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(CalendarBlockModel.fromFirestore).toList());
  }

  // Firestore transaction ile rezervasyon oluştur
  Future<void> createBooking({
    required String trainerId,
    required String memberId,
    required String memberName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Deterministik ID → aynı slota çift rezervasyon engellenir
    final bookingId =
        '${trainerId}_${startTime.millisecondsSinceEpoch}';
    final ref = _db.collection(AppConstants.bookingsCollection).doc(bookingId);

    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Geçmiş bir tarihe rezervasyon yapılamaz.');
    }

    final memberRef =
        _db.collection(AppConstants.membersCollection).doc(memberId);

    await _db.runTransaction((tx) async {
      // Slot çakışma kontrolü
      final existing = await tx.get(ref);
      if (existing.exists) {
        final status = existing.data()?['status'] as String?;
        if (status == 'confirmed' || status == 'pending_cancel') {
          throw Exception('Bu saat zaten rezerve edilmiş.');
        }
      }

      // Paket kalan ders kontrolü
      final memberDoc = await tx.get(memberRef);
      final remaining =
          (memberDoc.data()?['package']?['remaining'] as int?) ?? 0;
      if (remaining <= 0) {
        throw Exception(
            'Ders paketinizde kalan ders hakkınız bulunmuyor. PT\'niz ile iletişime geçin.');
      }

      tx.set(ref, {
        'trainerId': trainerId,
        'memberId': memberId,
        'memberName': memberName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'confirmed',
      });

      tx.update(memberRef, {
        'package.used': FieldValue.increment(1),
        'package.remaining': FieldValue.increment(-1),
      });
    });
  }

  // İptal talebi gönder
  Future<void> requestCancel(String bookingId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({
      'status': 'pending_cancel',
      'cancelRequestedAt': Timestamp.now(),
    });
  }

  // Üyenin tüm booking'lerini getir
  Stream<List<BookingModel>> myBookingsStream(String memberId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('memberId', isEqualTo: memberId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(BookingModel.fromFirestore).toList());
  }
}
