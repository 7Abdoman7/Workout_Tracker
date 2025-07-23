import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/core/database/database_helper.dart';
import 'package:workout_tracker/features/user/data/repositories/user_repository_impl.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:workout_tracker/features/user/presentation/screens/user_profile_screen.dart';
import 'package:workout_tracker/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:workout_tracker/features/live_workout/data/repositories/live_workout_repository_impl.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_bloc.dart';
import 'package:workout_tracker/features/history/data/repositories/workout_history_repository_impl.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

final databaseHelper = DatabaseHelper();

void main() {
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final userRepository = UserRepositoryImpl(databaseHelper: databaseHelper);

  runApp(MyApp(userRepository: userRepository));
}

class MyApp extends StatelessWidget {
  final UserRepositoryImpl userRepository;

  const MyApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userRepository: userRepository),
        ),
        BlocProvider<WorkoutBloc>(
          create: (context) => WorkoutBloc(workoutRepository: WorkoutRepositoryImpl(databaseHelper: databaseHelper)),
        ),
        BlocProvider<LiveWorkoutBloc>(
          create: (context) => LiveWorkoutBloc(liveWorkoutRepository: LiveWorkoutRepositoryImpl(databaseHelper: databaseHelper)),
        ),
        BlocProvider<WorkoutHistoryBloc>(
          create: (context) => WorkoutHistoryBloc(workoutHistoryRepository: WorkoutHistoryRepositoryImpl(databaseHelper: databaseHelper)),
        ),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const UserProfileScreen(),
      ),
    );
  }
}
