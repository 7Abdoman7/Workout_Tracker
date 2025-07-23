
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/set_model.dart';

class Exercise extends Equatable {
  final int? id;
  final int workoutId;
  final int userId; // Added userId
  final String name;
  final List<ExerciseSet> sets;
  final int restTimeMinutes;
  final int restTimeSeconds;
  final int order;

  const Exercise({
    this.id,
    required this.workoutId,
    required this.userId, // Added userId
    required this.name,
    this.sets = const [],
    required this.restTimeMinutes,
    required this.restTimeSeconds,
    required this.order,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? 0,
      workoutId: map['workout_id'] ?? 0,
      userId: map['user_id'] ?? 0, // Added userId
      name: map['name'] ?? '',
      restTimeMinutes: map['rest_time_minutes'] ?? 0,
      restTimeSeconds: map['rest_time_seconds'] ?? 0,
      order: map['exercise_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'user_id': userId, // Added userId
      'name': name,
      'rest_time_minutes': restTimeMinutes,
      'rest_time_seconds': restTimeSeconds,
      'exercise_order': order,
    };
  }

  Exercise copyWith({
    int? id,
    int? workoutId,
    int? userId, // Added userId
    String? name,
    List<ExerciseSet>? sets,
    int? restTimeMinutes,
    int? restTimeSeconds,
    int? order,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      userId: userId ?? this.userId, // Added userId
      name: name ?? this.name,
      sets: sets ?? this.sets,
      restTimeMinutes: restTimeMinutes ?? this.restTimeMinutes,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        userId, // Added userId
        name,
        sets,
        restTimeMinutes,
        restTimeSeconds,
        order,
      ];
}
