import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_error.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(this._auth, this._firestore);

  // PT: Telefon numarasına OTP gönder
  Future<String> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onFailed,
  }) async {
    String verificationIdResult = '';
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: (verificationId, resendToken) {
        verificationIdResult = verificationId;
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return verificationIdResult;
  }

  // PT: OTP ile giriş
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthError('OTP doğrulama hatası: ${e.message}');
    }
  }

  // Üye: Telefon + erişim kodu ile giriş
  Future<MemberLoginResult> loginWithAccessCode({
    required String phone,
    required String accessCode,
  }) async {
    try {
      // Üyeyi bul: phone + accessCode kombinasyonu
      final snapshot = await _firestore
          .collection(AppConstants.membersCollection)
          .where('phone', isEqualTo: phone)
          .where('accessCode', isEqualTo: accessCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const AuthError('Telefon numarası veya erişim kodu hatalı.');
      }

      final memberDoc = snapshot.docs.first;
      final memberId = memberDoc.id;
      final trainerId = memberDoc.data()['trainerId'] as String;
      final status = memberDoc.data()['status'] as String;

      if (status != 'active') {
        throw const AuthError(
            'Hesabınız pasif durumda. PT\'niz ile iletişime geçin.');
      }

      // Anonymous sign-in ile oturum aç (üye için)
      final userCred = await _auth.signInAnonymously();

      // users koleksiyonuna üye kaydı oluştur/güncelle
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCred.user!.uid)
          .set({
        'role': 'member',
        'name': memberDoc.data()['name'],
        'phone': phone,
        'memberId': memberId,
        'trainerId': trainerId,
      }, SetOptions(merge: true));

      return MemberLoginResult(
        uid: userCred.user!.uid,
        memberId: memberId,
        trainerId: trainerId,
      );
    } on AuthError {
      rethrow;
    } catch (e) {
      throw AuthError('Giriş hatası: $e');
    }
  }

  // Mevcut kullanıcı verilerini getir
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // PT kaydı: users + trainers koleksiyonu
  Future<void> registerAsPT({
    required String uid,
    required String name,
    required String phone,
  }) async {
    final batch = _firestore.batch();

    final userRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    final trainerRef = _firestore
        .collection(AppConstants.trainersCollection)
        .doc(uid);

    batch.set(userRef, {
      'role': 'pt',
      'name': name,
      'phone': phone,
    });

    batch.set(trainerRef, {
      'userId': uid,
      'slotDuration': 60,
      'breakDuration': 15,
      'activeMembers': [],
      'passiveMembers': [],
      'workStartHour': 9,
      'workEndHour': 20,
      'blockedDays': [],
    });

    await batch.commit();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

class MemberLoginResult {
  final String uid;
  final String memberId;
  final String trainerId;

  const MemberLoginResult({
    required this.uid,
    required this.memberId,
    required this.trainerId,
  });
}
