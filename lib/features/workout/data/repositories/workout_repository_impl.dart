

import 'package:workout_tracker/core/database/database_helper.dart';
import 'package:workout_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/workout_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  @override
  Future<Workout> addWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('workouts', workout.toMap());
    return workout.copyWith(id: id);
  }

  @override
  Future<void> deleteWorkout(int workoutId) async {
    final db = await _databaseHelper.database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [workoutId]);
  }

  @override
  Future<List<Workout>> getWorkouts(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'workout_order ASC',
    );
    List<Workout> workouts = [];
    for (var map in maps) {
      final workout = Workout.fromMap(map);
      final exercises = await getExercisesForWorkout(workout.id!); // Fetch exercises for each workout
      workouts.add(workout.copyWith(exercises: exercises));
    }
    return workouts;
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  @override
  Future<void> reorderWorkouts(int userId, int oldIndex, int newIndex) async {
    final db = await _databaseHelper.database;
    final workouts = await getWorkouts(userId);

    final movedWorkout = workouts.removeAt(oldIndex);
    workouts.insert(newIndex, movedWorkout);

    for (int i = 0; i < workouts.length; i++) {
      await db.update(
        'workouts',
        {'workout_order': i},
        where: 'id = ?',
        whereArgs: [workouts[i].id],
      );
    }
  }

  @override
  Future<Exercise> addExercise(Exercise exercise) async {
    final id = await _databaseHelper.insertExercise(exercise);
    return exercise.copyWith(id: id);
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    await _databaseHelper.deleteExercise(exerciseId);
  }

  @override
  Future<List<Exercise>> getExercisesForWorkout(int workoutId) async {
    return await _databaseHelper.getExercisesForWorkout(workoutId);
  }

  @override
  Future<void> updateExercise(Exercise exercise) async {
    await _databaseHelper.updateExercise(exercise);
  }

  @override
  Future<void> reorderExercises(int workoutId, int oldIndex, int newIndex) async {
    final db = await _databaseHelper.database;
    final exercises = await getExercisesForWorkout(workoutId);

    final movedExercise = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, movedExercise);

    for (int i = 0; i < exercises.length; i++) {
      await db.update(
        'exercises',
        {'exercise_order': i},
        where: 'id = ?',
        whereArgs: [exercises[i].id],
      );
    }
  }
}
