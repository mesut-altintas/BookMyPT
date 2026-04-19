import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/code_generator.dart';
import '../models/member_model.dart';

class MembersFirestoreDataSource {
  final FirebaseFirestore _db;

  MembersFirestoreDataSource(this._db);

  Stream<List<MemberModel>> membersStream(String trainerId) {
    return _db
        .collection(AppConstants.membersCollection)
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((s) => s.docs.map(MemberModel.fromFirestore).toList());
  }

  Future<MemberModel> addMember({
    required String trainerId,
    required String name,
    required String phone,
  }) async {
    final accessCode = CodeGenerator.generateAccessCode();
    final memberRef = _db.collection(AppConstants.membersCollection).doc();

    final member = MemberModel(
      id: memberRef.id,
      trainerId: trainerId,
      userId: '',
      name: name,
      phone: phone,
      status: MemberStatus.active,
      accessCode: accessCode,
      package: const MemberPackage(total: 0, used: 0),
    );

    final batch = _db.batch();

    batch.set(memberRef, member.toFirestore());

    // Trainer'ın activeMembers listesine ekle
    batch.update(
      _db.collection(AppConstants.trainersCollection).doc(trainerId),
      {
        'activeMembers': FieldValue.arrayUnion([memberRef.id])
      },
    );

    await batch.commit();
    return member;
  }

  Future<void> updateMemberStatus(
    String trainerId,
    String memberId,
    MemberStatus status,
  ) async {
    final batch = _db.batch();
    final memberRef =
        _db.collection(AppConstants.membersCollection).doc(memberId);
    final trainerRef =
        _db.collection(AppConstants.trainersCollection).doc(trainerId);

    batch.update(memberRef, {
      'status': status == MemberStatus.active ? 'active' : 'passive',
    });

    if (status == MemberStatus.active) {
      batch.update(trainerRef, {
        'activeMembers': FieldValue.arrayUnion([memberId]),
        'passiveMembers': FieldValue.arrayRemove([memberId]),
      });
    } else {
      batch.update(trainerRef, {
        'passiveMembers': FieldValue.arrayUnion([memberId]),
        'activeMembers': FieldValue.arrayRemove([memberId]),
      });
    }

    await batch.commit();
  }

  Future<void> updateCalendarAccess(String memberId, bool access) {
    return _db
        .collection(AppConstants.membersCollection)
        .doc(memberId)
        .update({'calendarAccess': access});
  }

  Future<void> updatePackage(String memberId, MemberPackage package) {
    return _db
        .collection(AppConstants.membersCollection)
        .doc(memberId)
        .update({'package': package.toMap()});
  }

  Future<void> deleteMember(String trainerId, String memberId) async {
    final batch = _db.batch();
    batch.delete(_db.collection(AppConstants.membersCollection).doc(memberId));
    batch.update(
      _db.collection(AppConstants.trainersCollection).doc(trainerId),
      {
        'activeMembers': FieldValue.arrayRemove([memberId]),
        'passiveMembers': FieldValue.arrayRemove([memberId]),
      },
    );
    await batch.commit();
  }
}
