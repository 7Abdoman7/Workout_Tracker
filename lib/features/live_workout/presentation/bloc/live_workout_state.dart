
import 'package:equatable/equatable.dart';

import 'package:workout_tracker/models/workout_model.dart';

class LiveWorkoutState extends Equatable {
  final Workout? currentWorkout;
  final int currentExerciseIndex;
  final Map<int, List<Map<String, dynamic>>> loggedReps; // exerciseIndex -> list of maps for each set, containing reps, weight, rpm, rir
  final bool workoutCompleted;

  const LiveWorkoutState({
    this.currentWorkout,
    this.currentExerciseIndex = 0,
    this.loggedReps = const {},
    this.workoutCompleted = false,
  });

  LiveWorkoutState copyWith({
    Workout? currentWorkout,
    int? currentExerciseIndex,
    Map<int, List<Map<String, dynamic>>>? loggedReps,
    bool? workoutCompleted,
  }) {
    return LiveWorkoutState(
      currentWorkout: currentWorkout ?? this.currentWorkout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      loggedReps: loggedReps ?? this.loggedReps,
      workoutCompleted: workoutCompleted ?? this.workoutCompleted,
    );
  }

  @override
  List<Object?> get props => [
        currentWorkout,
        currentExerciseIndex,
        loggedReps,
        workoutCompleted,
      ];
}
