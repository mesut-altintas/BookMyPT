import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/session_model.dart';

final ptSessionsProvider =
    StreamProvider.family<List<SessionModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <SessionModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final sessions =
            snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
        sessions.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return sessions;
      }).handleError((e, st) {});
});

final upcomingSessionsProvider =
    StreamProvider.family<List<SessionModel>, String>((ref, ptId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <SessionModel>[]);
  final now = DateTime.now();
  final weekLater = now.add(const Duration(days: 7));
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('ptId', isEqualTo: ptId)
      .snapshots()
      .map((snap) {
        final sessions =
            snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
        return sessions
            .where((s) =>
                s.dateTime.isAfter(now) && s.dateTime.isBefore(weekLater))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }).handleError((e, st) {});
});

final ptMemberSessionsProvider = StreamProvider.family<List<SessionModel>,
    ({String ptId, String memberId})>((ref, params) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <SessionModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('ptId', isEqualTo: params.ptId)
      .where('memberId', isEqualTo: params.memberId)
      .snapshots()
      .map((snap) {
        final sessions =
            snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
        sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return sessions;
      }).handleError((e, st) {});
});

final memberSessionsProvider =
    StreamProvider.family<List<SessionModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <SessionModel>[]);
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final sessions =
            snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
        sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return sessions;
      }).handleError((e, st) {});
});

final memberPtIdProvider = FutureProvider.family<String, String>((ref, memberId) async {
  final sessionsSnap = await FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('memberId', isEqualTo: memberId)
      .limit(1)
      .get();
  if (sessionsSnap.docs.isNotEmpty) {
    return sessionsSnap.docs.first.data()['ptId'] as String? ?? '';
  }
  final programsSnap = await FirebaseFirestore.instance
      .collection('programs')
      .where('memberId', isEqualTo: memberId)
      .limit(1)
      .get();
  if (programsSnap.docs.isNotEmpty) {
    return programsSnap.docs.first.data()['ptId'] as String? ?? '';
  }
  return '';
});

final memberUpcomingSessionsProvider =
    StreamProvider.family<List<SessionModel>, String>((ref, memberId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(const <SessionModel>[]);
  final now = DateTime.now();
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .where('memberId', isEqualTo: memberId)
      .snapshots()
      .map((snap) {
        final sessions =
            snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
        return sessions
            .where((s) =>
                s.dateTime.isAfter(now) &&
                (s.status == SessionStatus.pending ||
                    s.status == SessionStatus.confirmed))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }).handleError((e, st) {});
});

final sessionDetailProvider =
    StreamProvider.family<SessionModel?, String>((ref, sessionId) {
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.sessionsCollection)
      .doc(sessionId)
      .snapshots()
      .map((d) => d.exists ? SessionModel.fromFirestore(d) : null)
      .handleError((e, st) {});
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(FirebaseFirestore.instance);
});

class SessionRepository {
  const SessionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> createSession(SessionModel session) async {
    final doc =
        _firestore.collection(AppConstants.sessionsCollection).doc();
    final newSession = session.copyWith(id: doc.id);
    await doc.set(newSession.toFirestore());
    return doc.id;
  }

  Future<void> updateStatus(String sessionId, SessionStatus status) =>
      _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({'status': status.value});

  Future<void> updateSession(String id, Map<String, dynamic> data) =>
      _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(id)
          .update(data);

  Future<void> deleteSession(String id) =>
      _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(id)
          .delete();

  Future<List<SessionModel>> getSessionsByDate(
      String ptId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _firestore
        .collection(AppConstants.sessionsCollection)
        .where('ptId', isEqualTo: ptId)
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end))
        .get();
    final sessions =
        snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
    sessions.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sessions;
  }
}
