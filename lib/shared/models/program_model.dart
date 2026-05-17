import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Exercise ─────────────────────────────────────────────────────────────────

/// Exercise type constants
class ExerciseType {
  static const strength   = 'strength';
  static const cardio     = 'cardio';
  static const stretching = 'stretching';
}

class ExerciseModel {
  /// 'strength' | 'cardio' | 'stretching'  (defaults to 'strength' for legacy data)
  final String type;
  final String name;

  // ── Strength & Stretching ──
  final int sets;
  final int reps;           // used by strength only
  final int? restSeconds;   // rest between sets (strength)
  final double? weight;     // kg (strength)

  // ── Cardio & Stretching ──
  final int? durationSeconds; // cardio: total duration; stretching: hold duration per set

  // ── Cardio only ──
  final double? distanceMeters;

  // ── Common ──
  final String? notes;
  final String? videoUrl;
  final String? imageUrl;

  const ExerciseModel({
    this.type = ExerciseType.strength,
    required this.name,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds,
    this.weight,
    this.durationSeconds,
    this.distanceMeters,
    this.notes,
    this.videoUrl,
    this.imageUrl,
  });

  bool get isStrength   => type == ExerciseType.strength;
  bool get isCardio     => type == ExerciseType.cardio;
  bool get isStretching => type == ExerciseType.stretching;

  factory ExerciseModel.fromMap(Map<String, dynamic> map) => ExerciseModel(
        type:            map['type'] as String? ?? ExerciseType.strength,
        name:            map['name'] as String? ?? '',
        sets:            map['sets'] as int? ?? 3,
        reps:            map['reps'] as int? ?? 10,
        restSeconds:     map['restSeconds'] as int?,
        weight:          (map['weight'] as num?)?.toDouble(),
        durationSeconds: map['durationSeconds'] as int?,
        distanceMeters:  (map['distanceMeters'] as num?)?.toDouble(),
        notes:           map['notes'] as String?,
        videoUrl:        map['videoUrl'] as String?,
        imageUrl:        map['imageUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'sets': sets,
        'reps': reps,
        if (restSeconds != null)     'restSeconds': restSeconds,
        if (weight != null)          'weight': weight,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (distanceMeters != null)  'distanceMeters': distanceMeters,
        if (notes != null)           'notes': notes,
        if (videoUrl != null)        'videoUrl': videoUrl,
        if (imageUrl != null)        'imageUrl': imageUrl,
      };

  ExerciseModel copyWith({
    String?  type,
    String?  name,
    int?     sets,
    int?     reps,
    int?     restSeconds,
    double?  weight,
    int?     durationSeconds,
    double?  distanceMeters,
    String?  notes,
    String?  videoUrl,
    String?  imageUrl,
  }) =>
      ExerciseModel(
        type:            type            ?? this.type,
        name:            name            ?? this.name,
        sets:            sets            ?? this.sets,
        reps:            reps            ?? this.reps,
        restSeconds:     restSeconds     ?? this.restSeconds,
        weight:          weight          ?? this.weight,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        distanceMeters:  distanceMeters  ?? this.distanceMeters,
        notes:           notes           ?? this.notes,
        videoUrl:        videoUrl        ?? this.videoUrl,
        imageUrl:        imageUrl        ?? this.imageUrl,
      );
}

// ─── WorkoutDay ───────────────────────────────────────────────────────────────

class WorkoutDay {
  final String dayName;
  final List<ExerciseModel> exercises;
  final bool isRestDay;

  const WorkoutDay({
    required this.dayName,
    required this.exercises,
    this.isRestDay = false,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> map) => WorkoutDay(
        dayName:   map['dayName'] as String? ?? '',
        exercises: (map['exercises'] as List<dynamic>? ?? [])
            .map((e) => ExerciseModel.fromMap(e as Map<String, dynamic>))
            .toList(),
        isRestDay: map['isRestDay'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'dayName':   dayName,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'isRestDay': isRestDay,
      };
}

// ─── WorkoutWeek ──────────────────────────────────────────────────────────────

class WorkoutWeek {
  final int weekNumber;
  final List<WorkoutDay> days;

  const WorkoutWeek({
    required this.weekNumber,
    required this.days,
  });

  factory WorkoutWeek.fromMap(Map<String, dynamic> map) => WorkoutWeek(
        weekNumber: map['weekNumber'] as int? ?? 1,
        days:       (map['days'] as List<dynamic>? ?? [])
            .map((d) => WorkoutDay.fromMap(d as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'weekNumber': weekNumber,
        'days':       days.map((d) => d.toMap()).toList(),
      };
}

// ─── ProgramModel ─────────────────────────────────────────────────────────────

class ProgramModel {
  final String id;
  final String ptId;
  final String memberId;
  final String memberName;
  final String title;
  final String? description;
  final List<WorkoutWeek> weeks;
  final DateTime createdAt;
  final bool isActive;

  const ProgramModel({
    required this.id,
    required this.ptId,
    required this.memberId,
    required this.memberName,
    required this.title,
    this.description,
    required this.weeks,
    required this.createdAt,
    this.isActive = true,
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel(
      id:          doc.id,
      ptId:        data['ptId']       as String? ?? '',
      memberId:    data['memberId']   as String? ?? '',
      memberName:  data['memberName'] as String? ?? '',
      title:       data['title']      as String? ?? '',
      description: data['description'] as String?,
      weeks:       (data['weeks'] as List<dynamic>? ?? [])
          .map((w) => WorkoutWeek.fromMap(w as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive:  data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ptId':       ptId,
        'memberId':   memberId,
        'memberName': memberName,
        'title':      title,
        if (description != null) 'description': description,
        'weeks':     weeks.map((w) => w.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'isActive':  isActive,
      };
}
