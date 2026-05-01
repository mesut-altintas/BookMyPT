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
  });

  factory MemberProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberProfile(
      memberId: doc.id,
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
    );
  }

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
      );
}
