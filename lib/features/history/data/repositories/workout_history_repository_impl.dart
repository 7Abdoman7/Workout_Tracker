

import 'package:workout_tracker/core/database/database_helper.dart';
import 'package:workout_tracker/features/history/domain/repositories/workout_history_repository.dart';
import 'package:workout_tracker/models/exercise_history_model.dart';
import 'package:workout_tracker/models/workout_history_model.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutHistoryRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

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
