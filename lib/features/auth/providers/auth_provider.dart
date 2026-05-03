import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final ptUserProvider = StreamProvider.family<UserModel?, String>((ref, ptId) {
  if (ptId.isEmpty) return Stream.value(null);
  if (ref.watch(currentUserProvider).valueOrNull == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(ptId)
      .snapshots()
      .map((d) => d.exists ? UserModel.fromFirestore(d) : null);
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(authUser.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final model = UserModel.fromFirestore(doc);
        if (model.name.isNotEmpty) return model;
        // Fallback chain: Firebase Auth displayName → email prefix
        final fallback = (authUser.displayName?.isNotEmpty == true)
            ? authUser.displayName!
            : (authUser.email?.split('@').first ?? '');
        return model.copyWith(name: fallback);
      })
      .handleError((_) => null);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
  );
});

class AuthRepository {
  const AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid).set(
            UserModel(
              uid: uid,
              role: role,
              name: name,
              email: email,
              createdAt: DateTime.now(),
            ).toFirestore(),
          );

  Future<void> updateFcmToken(String uid, String token) =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'fcmToken': token});

  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);

  Future<void> updatePhotoUrl({
    required String uid,
    required String? ptId,
    required String url,
  }) async {
    // Core update — must succeed
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'photoUrl': url});
    await _auth.currentUser?.updatePhotoURL(url);

    // Best-effort secondary updates — don't fail the whole operation
    try {
      if (ptId != null && ptId.isNotEmpty) {
        await _firestore
            .collection(AppConstants.ptsCollection)
            .doc(ptId)
            .collection(AppConstants.membersSubCollection)
            .doc(uid)
            .update({'photoUrl': url});
      }

      final chatSnaps = await Future.wait([
        _firestore
            .collection(AppConstants.chatsCollection)
            .where('ptId', isEqualTo: uid)
            .get(),
        _firestore
            .collection(AppConstants.chatsCollection)
            .where('memberId', isEqualTo: uid)
            .get(),
      ]);

      await Future.wait([
        ...chatSnaps[0].docs.map((d) => d.reference.update({'ptPhotoUrl': url})),
        ...chatSnaps[1].docs.map((d) => d.reference.update({'memberPhotoUrl': url})),
      ]);
    } catch (_) {}
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._repo) : super(const AsyncValue.data(null));

  final AuthRepository _repo;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.signInWithEmail(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final cred = await _repo.registerWithEmail(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      state = const AsyncValue.data(null);
      return cred.user!.uid;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.signInWithGoogle();
      if (result == null) {
        state = const AsyncValue.data(null);
        return;
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.signOut);
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.sendPasswordResetEmail(email),
    );
  }

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.createUserProfile(
        uid: uid,
        name: name,
        email: email,
        role: role,
      ),
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

// Watches the member's slot in the PT's subcollection.
// If the PT removes the member, this clears the member's own ptId.
final membershipGuardProvider = StreamProvider.autoDispose<void>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || !user.isMember) return Stream.value(null);
  final ptId = user.ptId;
  if (ptId == null || ptId.isEmpty) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection(AppConstants.ptsCollection)
      .doc(ptId)
      .collection(AppConstants.membersSubCollection)
      .doc(user.uid)
      .snapshots()
      .asyncMap((snap) async {
        if (!snap.exists) {
          try {
            await FirebaseFirestore.instance
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .update({'ptId': ''});
          } catch (_) {}
        }
      });
});
