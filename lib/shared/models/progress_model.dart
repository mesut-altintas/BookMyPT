import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMeasurements {
  final double? chest;
  final double? waist;
  final double? hips;
  final double? bicep;
  final double? thigh;
  final double? bodyFatPercent;

  const BodyMeasurements({
    this.chest,
    this.waist,
    this.hips,
    this.bicep,
    this.thigh,
    this.bodyFatPercent,
  });

  factory BodyMeasurements.fromMap(Map<String, dynamic> map) =>
      BodyMeasurements(
        chest: (map['chest'] as num?)?.toDouble(),
        waist: (map['waist'] as num?)?.toDouble(),
        hips: (map['hips'] as num?)?.toDouble(),
        bicep: (map['bicep'] as num?)?.toDouble(),
        thigh: (map['thigh'] as num?)?.toDouble(),
        bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (chest != null) 'chest': chest,
        if (waist != null) 'waist': waist,
        if (hips != null) 'hips': hips,
        if (bicep != null) 'bicep': bicep,
        if (thigh != null) 'thigh': thigh,
        if (bodyFatPercent != null) 'bodyFatPercent': bodyFatPercent,
      };
}

class ProgressModel {
  final String id;
  final String memberId;
  final DateTime date;
  final double? weight;
  final BodyMeasurements? measurements;
  final String? photoUrl;
  final String? notes;

  const ProgressModel({
    required this.id,
    required this.memberId,
    required this.date,
    this.weight,
    this.measurements,
    this.photoUrl,
    this.notes,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (data['weight'] as num?)?.toDouble(),
      measurements: data['measurements'] != null
          ? BodyMeasurements.fromMap(
              data['measurements'] as Map<String, dynamic>)
          : null,
      photoUrl: data['photoUrl'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'memberId': memberId,
        'date': Timestamp.fromDate(date),
        if (weight != null) 'weight': weight,
        if (measurements != null) 'measurements': measurements!.toMap(),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (notes != null) 'notes': notes,
      };
}
