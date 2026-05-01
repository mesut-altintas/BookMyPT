import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/program_model.dart';

final ptMemberProgramsProvider = StreamProvider.family<List<ProgramModel>,
    ({String ptId, String memberId})>((ref, params) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('ptId', isEqualTo: params.ptId)
      .where('memberId', isEqualTo: params.memberId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => ProgramModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((e, st) {});
});

final ptProgramsProvider =
    StreamProvider.family<List<ProgramModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => ProgramModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((e, st) {});
});

final memberProgramsProvider =
    StreamProvider.family<List<ProgramModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <ProgramModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final list =
            snap.docs.map((d) => ProgramModel.fromFirestore(d)).toList();
        return list
            .where((p) => p.isActive)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }).handleError((e, st) {});
});

final programDetailProvider =
    StreamProvider.family<ProgramModel?, String>((ref, programId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.programsCollection)
      .doc(programId)
      .snapshots()
      .map((d) => d.exists ? ProgramModel.fromFirestore(d) : null)
      .handleError((e, st) {});
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
