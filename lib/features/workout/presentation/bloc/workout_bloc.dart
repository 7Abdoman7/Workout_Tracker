import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_event.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository workoutRepository;

  WorkoutBloc({required this.workoutRepository}) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<AddWorkout>(_onAddWorkout);
    on<UpdateWorkout>(_onUpdateWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
    on<ReorderWorkouts>(_onReorderWorkouts);
    on<AddExercise>(_onAddExercise);
    on<UpdateExercise>(_onUpdateExercise);
    on<DeleteExercise>(_onDeleteExercise);
    on<ReorderExercises>(_onReorderExercises);
  }

  void _onLoadWorkouts(LoadWorkouts event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());
    try {
      final workouts = await workoutRepository.getWorkouts(event.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onAddWorkout(AddWorkout event, Emitter<WorkoutState> emit) async {
    try {
      final newWorkout = await workoutRepository.addWorkout(event.workout);
      final workouts = await workoutRepository.getWorkouts(newWorkout.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onUpdateWorkout(UpdateWorkout event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.updateWorkout(event.workout);
      final workouts = await workoutRepository.getWorkouts(event.workout.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onDeleteWorkout(DeleteWorkout event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.deleteWorkout(event.workoutId);
      final workouts = await workoutRepository.getWorkouts(event.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onReorderWorkouts(ReorderWorkouts event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.reorderWorkouts(
          event.userId, event.oldIndex, event.newIndex);
      final workouts = await workoutRepository.getWorkouts(event.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onAddExercise(AddExercise event, Emitter<WorkoutState> emit) async {
    try {
      final newExercise = await workoutRepository.addExercise(event.exercise);
      if (state is WorkoutLoaded) {
        final currentWorkouts = (state as WorkoutLoaded).workouts;
        final updatedWorkouts = currentWorkouts.map((workout) {
          if (workout.id == newExercise.workoutId) {
            return workout.copyWith(exercises: [...workout.exercises, newExercise]);
          }
          return workout;
        }).toList();
        emit(WorkoutLoaded(updatedWorkouts));
      } else {
        final workouts = await workoutRepository.getWorkouts(newExercise.userId);
        emit(WorkoutLoaded(workouts));
      }
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onUpdateExercise(UpdateExercise event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.updateExercise(event.exercise);
      final workouts = await workoutRepository.getWorkouts(event.exercise.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onDeleteExercise(DeleteExercise event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.deleteExercise(event.exerciseId);
      if (state is WorkoutLoaded) {
        final currentWorkouts = (state as WorkoutLoaded).workouts;
        final updatedWorkouts = currentWorkouts.map((workout) {
          if (workout.id == event.workoutId) {
            final updatedExercises = workout.exercises
                .where((exercise) => exercise.id != event.exerciseId)
                .toList();
            return workout.copyWith(exercises: updatedExercises);
          }
          return workout;
        }).toList();
        emit(WorkoutLoaded(updatedWorkouts));
      } else {
        final workouts = await workoutRepository.getWorkouts(event.userId);
        emit(WorkoutLoaded(workouts));
      }
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  void _onReorderExercises(ReorderExercises event, Emitter<WorkoutState> emit) async {
    try {
      await workoutRepository.reorderExercises(
          event.workoutId, event.oldIndex, event.newIndex);
      final workouts = await workoutRepository.getWorkouts(event.workoutId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }
}