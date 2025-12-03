
class SessionModel {
  final String id;
  final String dayName;
  final int dayNumber;
  final String monthName;
  final int durationMinutes;
  final String sessionType;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.dayName,
    required this.dayNumber,
    required this.monthName,
    required this.durationMinutes,
    required this.sessionType,
    required this.exercises,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayName': dayName,
      'dayNumber': dayNumber,
      'monthName': monthName,
      'durationMinutes': durationMinutes,
      'sessionType': sessionType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      dayName: json['dayName'] as String,
      dayNumber: json['dayNumber'] as int,
      monthName: json['monthName'] as String,
      durationMinutes: json['durationMinutes'] as int,
      sessionType: json['sessionType'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }


  SessionModel copyWith({
    String? id,
    String? dayName,
    int? dayNumber,
    String? monthName,
    int? durationMinutes,
    String? sessionType,
    List<ExerciseModel>? exercises,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      dayName: dayName ?? this.dayName,
      dayNumber: dayNumber ?? this.dayNumber,
      monthName: monthName ?? this.monthName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionType: sessionType ?? this.sessionType,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double loadKg;
  final String iconName;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.loadKg,
    required this.iconName,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'loadKg': loadKg,
      'iconName': iconName,
    };
  }


  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSeconds: json['restSeconds'] as int,
      loadKg: (json['loadKg'] as num).toDouble(),
      iconName: json['iconName'] as String,
    );
  }


  ExerciseModel copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    int? restSeconds,
    double? loadKg,
    String? iconName,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      loadKg: loadKg ?? this.loadKg,
      iconName: iconName ?? this.iconName,
    );
  }
}
