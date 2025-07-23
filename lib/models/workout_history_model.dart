
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/exercise_history_model.dart';

class WorkoutHistory extends Equatable {
  final int? id;
  final int userId;
  final String workoutName;
  final DateTime date;
  final List<ExerciseHistory> exercises;

  const WorkoutHistory({
    this.id,
    required this.userId,
    required this.workoutName,
    required this.date,
    this.exercises = const [],
  });

  factory WorkoutHistory.fromMap(Map<String, dynamic> map) {
    return WorkoutHistory(
      id: map['id'],
      userId: map['user_id'],
      workoutName: map['workout_name'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'workout_name': workoutName,
      'date': date.toIso8601String(),
    };
  }

  WorkoutHistory copyWith({
    int? id,
    int? userId,
    String? workoutName,
    DateTime? date,
    List<ExerciseHistory>? exercises,
  }) {
    return WorkoutHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutName: workoutName ?? this.workoutName,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [id, userId, workoutName, date, exercises];
}
