
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_bloc.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_event.dart';
import 'package:workout_tracker/features/history/presentation/bloc/workout_history_state.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final int userId;

  const WorkoutHistoryScreen({super.key, required this.userId});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutHistoryBloc>().add(LoadWorkoutHistory(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: BlocBuilder<WorkoutHistoryBloc, WorkoutHistoryState>(
        builder: (context, state) {
          if (state is WorkoutHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutHistoryLoaded) {
            if (state.history.isEmpty) {
              return const Center(child: Text('No workout history yet.'));
            }
            return ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final workoutHistory = state.history[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(workoutHistory.workoutName),
                    subtitle: Text(workoutHistory.date.toLocal().toString().split(' ')[0]),
                    children: workoutHistory.exercises.map((exercise) {
                      return ListTile(
                        title: Text(exercise.exerciseName),
                        subtitle: Text(
                            'Sets: ${exercise.setsCompleted}, Reps: ${exercise.repsCompleted}'),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          } else if (state is WorkoutHistoryError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}
