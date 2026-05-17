import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/stream_utils.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/program_model.dart';

/// Safely parses Firestore documents into [ProgramModel] objects,
/// skipping any document whose data is malformed instead of crashing the stream.
List<ProgramModel> _parseDocs(List<QueryDocumentSnapshot> docs) {
  final result = <ProgramModel>[];
  for (final doc in docs) {
    try {
      result.add(ProgramModel.fromFirestore(doc));
    } catch (e) {
      debugPrint('[programs] Skipping corrupt doc ${doc.id}: $e');
    }
  }
  return result;
}

final ptMemberProgramsProvider = StreamProvider.family<List<ProgramModel>,
    ({String ptId, String memberId})>((ref, params) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('ptId', isEqualTo: params.ptId)
      .where('memberId', isEqualTo: params.memberId)
      .snapshots()
      .map((snap) {
        final list = _parseDocs(snap.docs);
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).transform(safeList<ProgramModel>());
});

final ptProgramsProvider =
    StreamProvider.family<List<ProgramModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final list = _parseDocs(snap.docs);
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).transform(safeList<ProgramModel>());
});

final memberProgramsProvider =
    StreamProvider.family<List<ProgramModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        return _parseDocs(snap.docs)
            .where((p) => p.isActive)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }).transform(safeList<ProgramModel>());
});

final programDetailProvider =
    StreamProvider.family<ProgramModel?, String>((ref, programId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .doc(programId)
      .snapshots()
      .map((d) => d.exists ? ProgramModel.fromFirestore(d) : null)
      .transform(safeNullable<ProgramModel>());
});

final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  return ProgramRepository(FirebaseFirestore.instance);
});

class ProgramRepository {
  const ProgramRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> createProgram(ProgramModel program) async {
    final doc = _firestore.collection(AppConstants.programsCollection).doc();
    final newProgram = ProgramModel(
      id: doc.id,
      ptId: program.ptId,
      memberId: program.memberId,
      memberName: program.memberName,
      title: program.title,
      description: program.description,
      weeks: program.weeks,
      createdAt: program.createdAt,
      isActive: program.isActive,
    );
    await doc.set(newProgram.toFirestore());
    return doc.id;
  }

  Future<void> updateProgram(String id, Map<String, dynamic> data) =>
      _firestore
          .collection(AppConstants.programsCollection)
          .doc(id)
          .update(data);

  Future<void> deleteProgram(String id) =>
      _firestore
          .collection(AppConstants.programsCollection)
          .doc(id)
          .delete();
}
