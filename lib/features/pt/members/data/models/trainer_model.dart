import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerModel {
  final String id;
  final String userId;
  final String? selectedCalendarId;
  final int slotDuration;
  final int breakDuration;
  final List<String> activeMembers;
  final List<String> passiveMembers;
  final int workStartHour;
  final int workEndHour;
  // 1=Pazartesi … 7=Pazar (Dart weekday)
  final List<int> blockedDays;

  const TrainerModel({
    required this.id,
    required this.userId,
    this.selectedCalendarId,
    this.slotDuration = 60,
    this.breakDuration = 15,
    this.activeMembers = const [],
    this.passiveMembers = const [],
    this.workStartHour = 9,
    this.workEndHour = 20,
    this.blockedDays = const [],
  });

  factory TrainerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      selectedCalendarId: data['selectedCalendarId'],
      slotDuration: data['slotDuration'] ?? 60,
      breakDuration: data['breakDuration'] ?? 15,
      activeMembers: List<String>.from(data['activeMembers'] ?? []),
      passiveMembers: List<String>.from(data['passiveMembers'] ?? []),
      workStartHour: data['workStartHour'] ?? 9,
      workEndHour: data['workEndHour'] ?? 20,
      blockedDays: List<int>.from(data['blockedDays'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        if (selectedCalendarId != null)
          'selectedCalendarId': selectedCalendarId,
        'slotDuration': slotDuration,
        'breakDuration': breakDuration,
        'activeMembers': activeMembers,
        'passiveMembers': passiveMembers,
        'workStartHour': workStartHour,
        'workEndHour': workEndHour,
        'blockedDays': blockedDays,
      };

  TrainerModel copyWith({
    String? selectedCalendarId,
    int? slotDuration,
    int? breakDuration,
    List<String>? activeMembers,
    List<String>? passiveMembers,
    int? workStartHour,
    int? workEndHour,
    List<int>? blockedDays,
  }) =>
      TrainerModel(
        id: id,
        userId: userId,
        selectedCalendarId: selectedCalendarId ?? this.selectedCalendarId,
        slotDuration: slotDuration ?? this.slotDuration,
        breakDuration: breakDuration ?? this.breakDuration,
        activeMembers: activeMembers ?? this.activeMembers,
        passiveMembers: passiveMembers ?? this.passiveMembers,
        workStartHour: workStartHour ?? this.workStartHour,
        workEndHour: workEndHour ?? this.workEndHour,
        blockedDays: blockedDays ?? this.blockedDays,
      );
}
