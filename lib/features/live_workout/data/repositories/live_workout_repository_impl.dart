

import 'package:workout_tracker/core/database/database_helper.dart';
import 'package:workout_tracker/features/live_workout/domain/repositories/live_workout_repository.dart';
import 'package:workout_tracker/models/exercise_history_model.dart';
import 'package:workout_tracker/models/workout_history_model.dart';

class LiveWorkoutRepositoryImpl implements LiveWorkoutRepository {
  final DatabaseHelper _databaseHelper;

  LiveWorkoutRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  @override
  @override
  Future<WorkoutHistory> saveWorkoutHistory(WorkoutHistory workoutHistory) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('workout_history', workoutHistory.toMap());
    final savedWorkoutHistory = workoutHistory.copyWith(id: id);
    for (var exerciseHistory in workoutHistory.exercises) {
      await saveExerciseHistory(exerciseHistory.copyWith(workoutHistoryId: id));
    }
    return savedWorkoutHistory;
  }

  @override
  Future<void> saveExerciseHistory(ExerciseHistory exerciseHistory) async {
    final db = await _databaseHelper.database;
    await db.insert('exercise_history', exerciseHistory.toMap());
  }

  @override
  Future<List<WorkoutHistory>> getWorkoutHistory(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'workout_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    List<WorkoutHistory> history = [];
    for (var map in maps) {
      final workoutHistory = WorkoutHistory.fromMap(map);
      final exerciseHistory = await getExerciseHistoryForWorkout(workoutHistory.id!); // Fetch exercises for each workout history
      history.add(workoutHistory.copyWith(exercises: exerciseHistory));
    }
    return history;
  }

  @override
  Future<List<ExerciseHistory>> getExerciseHistoryForWorkout(int workoutHistoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'exercise_history',
      where: 'workout_history_id = ?',
      whereArgs: [workoutHistoryId],
    );
    return maps.map((map) => ExerciseHistory.fromMap(map)).toList();
  }
}
