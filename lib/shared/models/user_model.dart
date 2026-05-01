import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String role;
  final String name;
  final String email;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final String? bio;
  final String? phone;
  final String? ptId;

  const UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    this.bio,
    this.phone,
    this.ptId,
  });

  bool get isPt => role == 'pt';
  bool get isMember => role == 'member';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      role: data['role'] as String? ?? 'member',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: data['bio'] as String?,
      phone: data['phone'] as String?,
      ptId: data['ptId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'role': role,
        'name': name,
        'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (fcmToken != null) 'fcmToken': fcmToken,
        'createdAt': Timestamp.fromDate(createdAt),
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
      };

  UserModel copyWith({
    String? uid,
    String? role,
    String? name,
    String? email,
    String? photoUrl,
    String? fcmToken,
    DateTime? createdAt,
    String? bio,
    String? phone,
    String? ptId,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        role: role ?? this.role,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt ?? this.createdAt,
        bio: bio ?? this.bio,
        phone: phone ?? this.phone,
        ptId: ptId ?? this.ptId,
      );
}
