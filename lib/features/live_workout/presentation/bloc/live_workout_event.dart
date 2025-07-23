
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/workout_model.dart';

abstract class LiveWorkoutEvent extends Equatable {
  const LiveWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkoutSession extends LiveWorkoutEvent {
  final Workout workout;

  const StartWorkoutSession(this.workout);

  StartWorkoutSession copyWith({
    Workout? workout,
  }) {
    return StartWorkoutSession(workout ?? this.workout);
  }

  @override
  List<Object> get props => [workout];
}

class LogSet extends LiveWorkoutEvent {
  final int exerciseIndex;
  final int setIndex;
  final int repsCompleted;
  final double? weightCompleted;
  final int? rpmCompleted;
  final int? rirCompleted;

  const LogSet({
    required this.exerciseIndex,
    required this.setIndex,
    required this.repsCompleted,
    this.weightCompleted,
    this.rpmCompleted,
    this.rirCompleted,
  });

  @override
  List<Object?> get props => [
        exerciseIndex,
        setIndex,
        repsCompleted,
        weightCompleted,
        rpmCompleted,
        rirCompleted,
      ];
}

class EditLiveExercise extends LiveWorkoutEvent {
  final int exerciseIndex;
  final Exercise updatedExercise;

  const EditLiveExercise({
    required this.exerciseIndex,
    required this.updatedExercise,
  });

  @override
  List<Object> get props => [exerciseIndex, updatedExercise];
}

class CompleteWorkoutSession extends LiveWorkoutEvent {
  final int userId;

  const CompleteWorkoutSession(this.userId);

  @override
  List<Object> get props => [userId];
}

class NavigateExercise extends LiveWorkoutEvent {
  final int newIndex;

  const NavigateExercise(this.newIndex);

  @override
  List<Object> get props => [newIndex];
}
