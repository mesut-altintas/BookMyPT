import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/members_firestore_datasource.dart';
import '../../data/models/member_model.dart';

// DataSource provider
final membersDataSourceProvider = Provider<MembersFirestoreDataSource>((ref) {
  return MembersFirestoreDataSource(ref.watch(firestoreProvider));
});

// Üye listesi stream
final membersStreamProvider = StreamProvider<List<MemberModel>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(membersDataSourceProvider).membersStream(user.id);
});

// Filtre
enum MemberFilter { all, active, passive }

final memberFilterProvider = StateProvider<MemberFilter>((ref) => MemberFilter.all);

// Filtrelenmiş liste
final filteredMembersProvider = Provider<List<MemberModel>>((ref) {
  final all = ref.watch(membersStreamProvider).valueOrNull ?? [];
  final filter = ref.watch(memberFilterProvider);
  switch (filter) {
    case MemberFilter.all:
      return all;
    case MemberFilter.active:
      return all.where((m) => m.status == MemberStatus.active).toList();
    case MemberFilter.passive:
      return all.where((m) => m.status == MemberStatus.passive).toList();
  }
});

// İşlem notifier
class MembersNotifier extends StateNotifier<AsyncValue<void>> {
  final MembersFirestoreDataSource _ds;
  final String _trainerId;

  MembersNotifier(this._ds, this._trainerId) : super(const AsyncValue.data(null));

  Future<MemberModel?> addMember({
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final member = await _ds.addMember(
        trainerId: _trainerId,
        name: name,
        phone: phone,
      );
      state = const AsyncValue.data(null);
      return member;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> toggleStatus(MemberModel member) async {
    final newStatus = member.status == MemberStatus.active
        ? MemberStatus.passive
        : MemberStatus.active;
    await _ds.updateMemberStatus(_trainerId, member.id, newStatus);
  }

  Future<void> toggleCalendarAccess(MemberModel member) async {
    await _ds.updateCalendarAccess(member.id, !member.calendarAccess);
  }

  Future<void> updatePackage(MemberModel member, MemberPackage package) async {
    await _ds.updatePackage(member.id, package);
  }

  Future<void> deleteMember(String memberId) async {
    await _ds.deleteMember(_trainerId, memberId);
  }
}

final membersNotifierProvider =
    StateNotifierProvider<MembersNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  final ds = ref.watch(membersDataSourceProvider);
  return MembersNotifier(ds, user?.id ?? '');
});
