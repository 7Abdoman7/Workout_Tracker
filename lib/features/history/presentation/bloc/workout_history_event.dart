
import 'package:equatable/equatable.dart';


abstract class WorkoutHistoryEvent extends Equatable {
  const WorkoutHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkoutHistory extends WorkoutHistoryEvent {
  final int userId;

  const LoadWorkoutHistory(this.userId);

  @override
  List<Object> get props => [userId];
}
