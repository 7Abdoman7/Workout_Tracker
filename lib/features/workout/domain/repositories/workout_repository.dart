
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/workout_model.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getWorkouts(int userId);
  Future<Workout> addWorkout(Workout workout);
  Future<void> updateWorkout(Workout workout);
  Future<void> deleteWorkout(int workoutId);
  Future<void> reorderWorkouts(int userId, int oldIndex, int newIndex);
  Future<Exercise> addExercise(Exercise exercise);
  Future<void> updateExercise(Exercise exercise);
  Future<void> deleteExercise(int exerciseId);
  Future<List<Exercise>> getExercisesForWorkout(int workoutId);
  Future<void> reorderExercises(int workoutId, int oldIndex, int newIndex);
}
