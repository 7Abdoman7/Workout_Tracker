
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/history/domain/repositories/workout_history_repository.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_event.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_state.dart';

class WorkoutHistoryBloc extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  final WorkoutHistoryRepository workoutHistoryRepository;

  WorkoutHistoryBloc({required this.workoutHistoryRepository})
      : super(WorkoutHistoryInitial()) {
    on<LoadWorkoutHistory>(_onLoadWorkoutHistory);
  }

  void _onLoadWorkoutHistory(
      LoadWorkoutHistory event, Emitter<WorkoutHistoryState> emit) async {
    emit(WorkoutHistoryLoading());
    try {
      final history = await workoutHistoryRepository.getWorkoutHistory(event.userId);
      emit(WorkoutHistoryLoaded(history));
    } catch (e) {
      emit(WorkoutHistoryError(e.toString()));
    }
  }
}
