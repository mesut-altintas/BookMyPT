import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constants/app_constants.dart';
import '../models/booking_model.dart';
import '../models/calendar_block_model.dart';
import '../../../members/data/models/trainer_model.dart';

class CalendarFirestoreDataSource {
  final FirebaseFirestore _db;

  CalendarFirestoreDataSource(this._db);

  // Trainer stream
  Stream<TrainerModel?> trainerStream(String trainerId) {
    return _db
        .collection(AppConstants.trainersCollection)
        .doc(trainerId)
        .snapshots()
        .map((doc) => doc.exists ? TrainerModel.fromFirestore(doc) : null);
  }

  // Trainer güncelle
  Future<void> updateTrainer(String trainerId, Map<String, dynamic> data) {
    return _db
        .collection(AppConstants.trainersCollection)
        .doc(trainerId)
        .update(data);
  }

  // Bookings stream (tarih aralığı için)
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
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  // CalendarBlocks stream (tarih aralığı için)
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
        .map((snap) => snap.docs.map(CalendarBlockModel.fromFirestore).toList());
  }

  // Native calendar bloklarını toplu güncelle
  Future<void> syncNativeBlocks({
    required String trainerId,
    required DateTime start,
    required DateTime end,
    required List<Map<String, dynamic>> events,
  }) async {
    final batch = _db.batch();

    // Mevcut native blokları sil
    final existing = await _db
        .collection(AppConstants.calendarBlocksCollection)
        .where('trainerId', isEqualTo: trainerId)
        .where('source', isEqualTo: 'native_calendar')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTime', isLessThan: Timestamp.fromDate(end))
        .get();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    // Yeni blokları ekle
    for (final event in events) {
      final ref = _db.collection(AppConstants.calendarBlocksCollection).doc();
      batch.set(ref, {
        'trainerId': trainerId,
        'source': 'native_calendar',
        'externalEventId': event['id'],
        'title': event['title'],
        'startTime': Timestamp.fromDate(event['start'] as DateTime),
        'endTime': Timestamp.fromDate(event['end'] as DateTime),
      });
    }

    await batch.commit();
  }
}
