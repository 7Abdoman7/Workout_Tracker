
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/set_model.dart';
import 'package:workout_tracker/models/user_model.dart';
import 'package:workout_tracker/models/workout_history_model.dart';
import 'package:workout_tracker/models/exercise_history_model.dart';
import 'package:workout_tracker/models/workout_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'workout_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        workout_order INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        rest_time_minutes INTEGER NOT NULL,
        rest_time_seconds INTEGER NOT NULL,
        exercise_order INTEGER,
        FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL,
        rpm INTEGER,
        rir INTEGER,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        workout_name TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
        CREATE TABLE exercise_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_history_id INTEGER NOT NULL,
            exercise_name TEXT NOT NULL,
            sets_completed TEXT NOT NULL,
            reps_completed TEXT NOT NULL,
            FOREIGN KEY (workout_history_id) REFERENCES workout_history(id) ON DELETE CASCADE
        )''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Remove old columns from exercises table
      await db.execute('''
        CREATE TABLE exercises_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          workout_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          rest_time_minutes INTEGER NOT NULL,
          rest_time_seconds INTEGER NOT NULL,
          exercise_order INTEGER,
          FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
        )''');
      await db.execute('''
        INSERT INTO exercises_new (id, workout_id, name, rest_time_minutes, rest_time_seconds, exercise_order)
        SELECT id, workout_id, name, rest_time_minutes, rest_time_seconds, exercise_order FROM exercises
      ''');
      await db.execute('DROP TABLE exercises');
      await db.execute('ALTER TABLE exercises_new RENAME TO exercises');

      // Create new exercise_sets table
      await db.execute('''
        CREATE TABLE exercise_sets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id INTEGER NOT NULL,
          set_number INTEGER NOT NULL,
          reps INTEGER NOT NULL,
          weight REAL,
          rpm INTEGER,
          rir INTEGER,
          FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
        )''');
    }
  }

  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getWorkouts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'workout_order ASC',
    );
    List<Workout> workouts = [];
    for (var workoutMap in maps) {
      final workout = Workout.fromMap(workoutMap);
      final exercises = await getExercisesForWorkout(workout.id!);
      workouts.add(workout.copyWith(exercises: exercises));
    }
    return workouts;
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    final exerciseId = await db.insert('exercises', exercise.toMap());
    for (var set in exercise.sets) {
      await insertExerciseSet(set.copyWith(exerciseId: exerciseId));
    }
    return exerciseId;
  }

  Future<int> insertExerciseSet(ExerciseSet set) async {
    final db = await database;
    return await db.insert('exercise_sets', set.toMap());
  }

  Future<List<ExerciseSet>> getExerciseSetsForExercise(int exerciseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'set_number ASC',
    );
    return List.generate(maps.length, (i) {
      return ExerciseSet.fromMap(maps[i]);
    });
  }

  Future<List<Exercise>> getExercisesForWorkout(int workoutId) async {
    final db = await database;
    final List<Map<String, dynamic>> exerciseMaps = await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'exercise_order ASC',
    );

    List<Exercise> exercises = [];
    for (var exerciseMap in exerciseMaps) {
      final exercise = Exercise.fromMap(exerciseMap);
      final sets = await getExerciseSetsForExercise(exercise.id!);
      exercises.add(exercise.copyWith(sets: sets));
    }
    return exercises;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    final rowsAffected = await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );

    // Delete existing sets for this exercise
    await db.delete(
      'exercise_sets',
      where: 'exercise_id = ?',
      whereArgs: [exercise.id],
    );

    // Insert new sets
    for (var set in exercise.sets) {
      await insertExerciseSet(set.copyWith(exerciseId: exercise.id));
    }

    return rowsAffected;
  }

  Future<int> updateExerciseSet(ExerciseSet set) async {
    final db = await database;
    return await db.update(
      'exercise_sets',
      set.toMap(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    await db.delete(
      'exercise_sets',
      where: 'exercise_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExerciseSet(int id) async {
    final db = await database;
    return await db.delete(
      'exercise_sets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserName(int id, String name) async {
    final db = await database;
    return await db.update(
      'users',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertWorkoutHistory(WorkoutHistory history) async {
    final db = await database;
    return await db.insert('workout_history', history.toMap());
  }

  Future<List<WorkoutHistory>> getWorkoutHistory(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return WorkoutHistory.fromMap(maps[i]);
    });
  }

  Future<int> insertExerciseHistory(ExerciseHistory history) async {
    final db = await database;
    return await db.insert('exercise_history', history.toMap());
  }

  Future<List<ExerciseHistory>> getExerciseHistoryForWorkout(int workoutHistoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_history',
      where: 'workout_history_id = ?',
      whereArgs: [workoutHistoryId],
    );
    return List.generate(maps.length, (i) {
      return ExerciseHistory.fromMap(maps[i]);
    });
  }
}
