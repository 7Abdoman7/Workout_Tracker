
import 'package:workout_tracker/models/exercise_history_model.dart';
import 'package:workout_tracker/models/workout_history_model.dart';

abstract class LiveWorkoutRepository {
  Future<WorkoutHistory> saveWorkoutHistory(WorkoutHistory workoutHistory);
  Future<void> saveExerciseHistory(ExerciseHistory exerciseHistory);
  Future<List<WorkoutHistory>> getWorkoutHistory(int userId);
  Future<List<ExerciseHistory>> getExerciseHistoryForWorkout(int workoutHistoryId);
}
