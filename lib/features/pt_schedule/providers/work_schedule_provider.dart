import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/work_schedule_model.dart';

/// Streams the PT's work schedule from their user document.
/// Returns null when no schedule has been saved yet.
final workScheduleProvider =
    StreamProvider.family<WorkSchedule?, String>((ref, ptId) {
  if (ptId.isEmpty) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(ptId)
      .snapshots()
      .map((doc) {
    final raw = doc.data()?['workSchedule'];
    if (raw == null) return null;
    return WorkSchedule.fromMap(Map<String, dynamic>.from(raw as Map));
  });
});

final workScheduleRepositoryProvider =
    Provider<WorkScheduleRepository>((_) => WorkScheduleRepository());

class WorkScheduleRepository {
  Future<void> save(String ptId, WorkSchedule schedule) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(ptId)
          .update({'workSchedule': schedule.toMap()});
}
