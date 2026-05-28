import 'package:cloud_firestore/cloud_firestore.dart';

class MemberProfile {
  final String memberId;
  final String name;
  final String email;
  final String? photoUrl;
  final String? goal;
  final String? notes;
  final DateTime joinedAt;
  final double? height;
  final double? startingWeight;
  final DateTime? birthDate;
  final String? phone;
  final int remainingSessions;
  final bool isActive;
  final int? sessionDurationMinutes;
  /// Remaining sessions keyed by duration in minutes.
  /// e.g. {45: 5, 60: 10} — from packages credited to this member.
  final Map<int, int> remainingSessionsByDuration;

  const MemberProfile({
    required this.memberId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.goal,
    this.notes,
    required this.joinedAt,
    this.height,
    this.startingWeight,
    this.birthDate,
    this.phone,
    this.remainingSessions = 0,
    this.isActive = true,
    this.sessionDurationMinutes,
    this.remainingSessionsByDuration = const {},
  });

  static Map<int, int> _parseDurationMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final result = <int, int>{};
    for (final entry in raw.entries) {
      final key = int.tryParse(entry.key.toString());
      final val = (entry.value as num?)?.toInt() ?? 0;
      if (key != null && val > 0) result[key] = val;
    }
    return result;
  }

  /// Durations that still have remaining sessions, sorted ascending.
  List<int> get availableDurations {
    return remainingSessionsByDuration.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  factory MemberProfile.fromMap(String id, Map<String, dynamic> data) {
    return MemberProfile(
      memberId: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      goal: data['goal'] as String?,
      notes: data['notes'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      height: (data['height'] as num?)?.toDouble(),
      startingWeight: (data['startingWeight'] as num?)?.toDouble(),
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      phone: data['phone'] as String?,
      remainingSessions: data['remainingSessions'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      sessionDurationMinutes: data['sessionDurationMinutes'] as int?,
      remainingSessionsByDuration:
          _parseDurationMap(data['remainingSessionsByDuration']),
    );
  }

  factory MemberProfile.fromFirestore(DocumentSnapshot doc) =>
      MemberProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);

  Map<String, dynamic> toFirestore() => {
        'memberId': memberId,
        'name': name,
        'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (goal != null) 'goal': goal,
        if (notes != null) 'notes': notes,
        'joinedAt': Timestamp.fromDate(joinedAt),
        if (height != null) 'height': height,
        if (startingWeight != null) 'startingWeight': startingWeight,
        if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
        if (phone != null) 'phone': phone,
        'remainingSessions': remainingSessions,
        'isActive': isActive,
        if (sessionDurationMinutes != null)
          'sessionDurationMinutes': sessionDurationMinutes,
        if (remainingSessionsByDuration.isNotEmpty)
          'remainingSessionsByDuration': remainingSessionsByDuration
              .map((k, v) => MapEntry(k.toString(), v)),
      };

  MemberProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? goal,
    String? notes,
    double? height,
    double? startingWeight,
    DateTime? birthDate,
    String? phone,
    int? remainingSessions,
    bool? isActive,
    int? sessionDurationMinutes,
    Map<int, int>? remainingSessionsByDuration,
  }) =>
      MemberProfile(
        memberId: memberId,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        goal: goal ?? this.goal,
        notes: notes ?? this.notes,
        joinedAt: joinedAt,
        height: height ?? this.height,
        startingWeight: startingWeight ?? this.startingWeight,
        birthDate: birthDate ?? this.birthDate,
        phone: phone ?? this.phone,
        remainingSessions: remainingSessions ?? this.remainingSessions,
        isActive: isActive ?? this.isActive,
        sessionDurationMinutes:
            sessionDurationMinutes ?? this.sessionDurationMinutes,
        remainingSessionsByDuration:
            remainingSessionsByDuration ?? this.remainingSessionsByDuration,
      );
}
