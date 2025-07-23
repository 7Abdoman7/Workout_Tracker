
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/workout_history_model.dart';

abstract class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();

  @override
  List<Object> get props => [];
}

class WorkoutHistoryInitial extends WorkoutHistoryState {}

class WorkoutHistoryLoading extends WorkoutHistoryState {}

class WorkoutHistoryLoaded extends WorkoutHistoryState {
  final List<WorkoutHistory> history;

  const WorkoutHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class WorkoutHistoryError extends WorkoutHistoryState {
  final String message;

  const WorkoutHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
