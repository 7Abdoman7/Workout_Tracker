
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/workout_model.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkouts extends WorkoutEvent {
  final int userId;

  const LoadWorkouts(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddWorkout extends WorkoutEvent {
  final Workout workout;

  const AddWorkout(this.workout);

  @override
  List<Object> get props => [workout];
}

class UpdateWorkout extends WorkoutEvent {
  final Workout workout;

  const UpdateWorkout(this.workout);

  @override
  List<Object> get props => [workout];
}

class DeleteWorkout extends WorkoutEvent {
  final int workoutId;
  final int userId;

  const DeleteWorkout(this.workoutId, this.userId);

  @override
  List<Object> get props => [workoutId, userId];
}

class ReorderWorkouts extends WorkoutEvent {
  final int userId;
  final int oldIndex;
  final int newIndex;

  const ReorderWorkouts(this.userId, this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [userId, oldIndex, newIndex];
}

class AddExercise extends WorkoutEvent {
  final Exercise exercise;
  final int userId;

  const AddExercise(this.exercise, this.userId);

  @override
  List<Object> get props => [exercise, userId];
}

class UpdateExercise extends WorkoutEvent {
  final Exercise exercise;
  final int userId;

  const UpdateExercise(this.exercise, this.userId);

  @override
  List<Object> get props => [exercise, userId];
}

class DeleteExercise extends WorkoutEvent {
  final int exerciseId;
  final int workoutId;
  final int userId;

  const DeleteExercise(this.exerciseId, this.workoutId, this.userId);

  @override
  List<Object> get props => [exerciseId, workoutId, userId];
}

class ReorderExercises extends WorkoutEvent {
  final int workoutId;
  final int oldIndex;
  final int newIndex;

  const ReorderExercises(this.workoutId, this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [workoutId, oldIndex, newIndex];
}
