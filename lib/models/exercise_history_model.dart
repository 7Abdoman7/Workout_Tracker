
import 'package:equatable/equatable.dart';

class ExerciseHistory extends Equatable {
  final int? id;
  final int workoutHistoryId;
  final String exerciseName;
  final String setsCompleted;
  final String repsCompleted;

  const ExerciseHistory({
    this.id,
    required this.workoutHistoryId,
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
  });

  factory ExerciseHistory.fromMap(Map<String, dynamic> map) {
    return ExerciseHistory(
      id: map['id'],
      workoutHistoryId: map['workout_history_id'],
      exerciseName: map['exercise_name'],
      setsCompleted: map['sets_completed'],
      repsCompleted: map['reps_completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_history_id': workoutHistoryId,
      'exercise_name': exerciseName,
      'sets_completed': setsCompleted,
      'reps_completed': repsCompleted,
    };
  }

  ExerciseHistory copyWith({
    int? id,
    int? workoutHistoryId,
    String? exerciseName,
    String? setsCompleted,
    String? repsCompleted,
  }) {
    return ExerciseHistory(
      id: id ?? this.id,
      workoutHistoryId: workoutHistoryId ?? this.workoutHistoryId,
      exerciseName: exerciseName ?? this.exerciseName,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      repsCompleted: repsCompleted ?? this.repsCompleted,
    );
  }

  @override
  List<Object?> get props =>
      [id, workoutHistoryId, exerciseName, setsCompleted, repsCompleted];
}
