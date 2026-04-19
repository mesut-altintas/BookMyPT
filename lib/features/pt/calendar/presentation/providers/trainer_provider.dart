import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../members/data/models/trainer_model.dart';
import '../../data/datasources/calendar_firestore_datasource.dart';

final calendarDataSourceProvider = Provider<CalendarFirestoreDataSource>((ref) {
  return CalendarFirestoreDataSource(ref.watch(firestoreProvider));
});

final trainerStreamProvider = StreamProvider<TrainerModel?>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(calendarDataSourceProvider).trainerStream(user.id);
});
