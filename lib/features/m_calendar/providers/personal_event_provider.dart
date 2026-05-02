import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/personal_event_model.dart';

final memberPersonalEventsProvider =
    StreamProvider.family<List<PersonalEventModel>, String>((ref, memberId) {
  if (memberId.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(AppConstants.personalEventsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) =>
          snap.docs.map(PersonalEventModel.fromFirestore).toList())
      .handleError((_, __) {});
});

final personalEventRepositoryProvider =
    Provider<PersonalEventRepository>((ref) {
  return PersonalEventRepository(FirebaseFirestore.instance);
});

class PersonalEventRepository {
  const PersonalEventRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createEvent(PersonalEventModel event) async {
    final ref =
        _firestore.collection(AppConstants.personalEventsCollection).doc();
    await ref.set(PersonalEventModel(
      id: ref.id,
      memberId: event.memberId,
      title: event.title,
      dateTime: event.dateTime,
      durationMinutes: event.durationMinutes,
      notes: event.notes,
      createdAt: event.createdAt,
    ).toFirestore());
  }

  Future<void> deleteEvent(String eventId) =>
      _firestore
          .collection(AppConstants.personalEventsCollection)
          .doc(eventId)
          .delete();
}
