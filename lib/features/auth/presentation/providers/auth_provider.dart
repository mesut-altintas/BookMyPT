import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// DataSource
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

// Auth state (Firebase user)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Current user model
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authDataSourceProvider).getCurrentUser();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRemoteDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _dataSource.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String? _verificationId;

  Future<void> sendOtp(
    String phoneNumber, {
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _dataSource.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId, _) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      onFailed: (e) => onError(e.message ?? 'OTP gönderilemedi'),
    );
  }

  Future<bool> verifyOtpAndGetUser(String smsCode) async {
    if (_verificationId == null) return false;
    state = const AsyncValue.loading();
    try {
      final cred = await _dataSource.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final user = await _dataSource.getCurrentUser();
      state = AsyncValue.data(user);
      if (cred.user != null) {
        FcmService.requestPermissionAndSaveToken(cred.user!.uid);
      }
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> registerAsPT({
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = _dataSource.currentFirebaseUser!.uid;
      await _dataSource.registerAsPT(uid: uid, name: name, phone: phone);
      final user = await _dataSource.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> loginAsMember({
    required String phone,
    required String accessCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.loginWithAccessCode(
        phone: phone,
        accessCode: accessCode,
      );
      final user = await _dataSource.getCurrentUser();
      state = AsyncValue.data(user);
      FcmService.requestPermissionAndSaveToken(result.uid);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await _dataSource.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authDataSourceProvider));
});
