


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/live_workout/domain/repositories/live_workout_repository.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_event.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_state.dart';
import 'package:workout_tracker/models/exercise_history_model.dart';
import 'package:workout_tracker/models/workout_history_model.dart';
import 'package:workout_tracker/models/exercise_model.dart';

class LiveWorkoutBloc extends Bloc<LiveWorkoutEvent, LiveWorkoutState> {
  final LiveWorkoutRepository liveWorkoutRepository;

  LiveWorkoutBloc({required this.liveWorkoutRepository})
      : super(const LiveWorkoutState()) {
    on<StartWorkoutSession>(_onStartWorkoutSession);
    on<LogSet>(_onLogSet);
    on<EditLiveExercise>(_onEditLiveExercise);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
    on<NavigateExercise>(_onNavigateExercise);
  }

  void _onStartWorkoutSession(
      StartWorkoutSession event, Emitter<LiveWorkoutState> emit) {
    emit(state.copyWith(
      currentWorkout: event.workout,
      currentExerciseIndex: 0,
      loggedReps: {},
      workoutCompleted: false,
    ));
  }

  void _onLogSet(LogSet event, Emitter<LiveWorkoutState> emit) {
    final currentLoggedSets = Map<int, List<Map<String, dynamic>>>.from(state.loggedReps);
    final exerciseSets = currentLoggedSets[event.exerciseIndex] ?? [];

    final newSet = {
      'reps': event.repsCompleted,
      'weight': event.weightCompleted,
      'rpm': event.rpmCompleted,
      'rir': event.rirCompleted,
    };

    if (event.setIndex < exerciseSets.length) {
      exerciseSets[event.setIndex] = newSet;
    } else {
      exerciseSets.add(newSet);
    }
    currentLoggedSets[event.exerciseIndex] = exerciseSets;

    emit(state.copyWith(loggedReps: currentLoggedSets));
  }

  void _onEditLiveExercise(
      EditLiveExercise event, Emitter<LiveWorkoutState> emit) {
    if (state.currentWorkout == null) return;

    final updatedExercises =
        List<Exercise>.from(state.currentWorkout!.exercises);
    updatedExercises[event.exerciseIndex] = event.updatedExercise;

    emit(state.copyWith(
      currentWorkout: state.currentWorkout!.copyWith(
        exercises: updatedExercises,
      ),
    ));
  }

  void _onCompleteWorkoutSession(
      CompleteWorkoutSession event, Emitter<LiveWorkoutState> emit) async {
    if (state.currentWorkout == null) return;

    final workoutHistory = WorkoutHistory(
      userId: event.userId,
      workoutName: state.currentWorkout!.name,
      date: DateTime.now(),
      exercises: [], // Will be populated with ExerciseHistory
    );

    final WorkoutHistory savedWorkoutHistory = await liveWorkoutRepository.saveWorkoutHistory(workoutHistory);

    for (int i = 0; i < state.currentWorkout!.exercises.length; i++) {
      final exercise = state.currentWorkout!.exercises[i];
      final loggedSets = state.loggedReps[i] ?? [];

      final exerciseHistory = ExerciseHistory(
        workoutHistoryId: savedWorkoutHistory.id!,
        exerciseName: exercise.name,
        setsCompleted: loggedSets.length.toString(),
        repsCompleted: loggedSets.map((set) => set['reps'].toString()).join(', '),
      );
      await liveWorkoutRepository.saveExerciseHistory(exerciseHistory);
    }

    emit(state.copyWith(workoutCompleted: true));
  }

  void _onNavigateExercise(
      NavigateExercise event, Emitter<LiveWorkoutState> emit) {
    emit(state.copyWith(currentExerciseIndex: event.newIndex));
  }
}
