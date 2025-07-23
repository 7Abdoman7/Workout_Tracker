
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_bloc.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_event.dart';
import 'package:workout_tracker/features/live_workout/presentation/bloc/live_workout_state.dart';

import 'package:workout_tracker/models/workout_model.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final int userId;

  const LiveWorkoutScreen({
    super.key,
    required this.workout,
    required this.userId,
  });

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LiveWorkoutBloc>().add(StartWorkoutSession(widget.workout));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Workout: ${widget.workout.name}'),
      ),
      body: BlocConsumer<LiveWorkoutBloc, LiveWorkoutState>(
        listener: (context, state) {
          if (state.workoutCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout Completed!')),
            );
            Navigator.pop(context); // Go back to workout detail screen
          }
        },
        builder: (context, state) {
          if (state.currentWorkout == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentExercise =
              state.currentWorkout!.exercises[state.currentExerciseIndex];
          final loggedReps = state.loggedReps[state.currentExerciseIndex] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise: ${currentExercise.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentExercise.sets.length,
                    itemBuilder: (context, setIndex) {
                      final set = currentExercise.sets[setIndex];
                      final loggedSet = loggedReps.length > setIndex ? loggedReps[setIndex] : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Set ${set.setNumber}'),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Reps (Target: ${set.reps})',
                                        hintText: loggedSet != null ? loggedSet['reps'].toString() : '',
                                      ),
                                      onChanged: (value) {
                                        // Handle reps change
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Weight (Target: ${set.weight ?? 'N/A'})',
                                        hintText: loggedSet != null ? loggedSet['weight'].toString() : '',
                                      ),
                                      onChanged: (value) {
                                        // Handle weight change
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'RPM (Target: ${set.rpm ?? 'N/A'})',
                                        hintText: loggedSet != null ? loggedSet['rpm'].toString() : '',
                                      ),
                                      onChanged: (value) {
                                        // Handle RPM change
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'RIR (Target: ${set.rir ?? 'N/A'})',
                                        hintText: loggedSet != null ? loggedSet['rir'].toString() : '',
                                      ),
                                      onChanged: (value) {
                                        // Handle RIR change
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Log set completion
                                  context.read<LiveWorkoutBloc>().add(
                                        LogSet(
                                          exerciseIndex: state.currentExerciseIndex,
                                          setIndex: setIndex,
                                          repsCompleted: int.tryParse(loggedSet?['reps'].toString() ?? '') ?? 0, // Placeholder
                                          weightCompleted: double.tryParse(loggedSet?['weight'].toString() ?? ''), // Placeholder
                                          rpmCompleted: int.tryParse(loggedSet?['rpm'].toString() ?? ''), // Placeholder
                                          rirCompleted: int.tryParse(loggedSet?['rir'].toString() ?? ''), // Placeholder
                                        ),
                                      );
                                },
                                child: const Text('Log Set'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (state.currentExerciseIndex > 0) {
                          context.read<LiveWorkoutBloc>().add(
                                NavigateExercise(state.currentExerciseIndex - 1),
                              );
                        }
                      },
                      child: const Text('Previous Exercise'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (state.currentExerciseIndex <
                            state.currentWorkout!.exercises.length - 1) {
                          context.read<LiveWorkoutBloc>().add(
                                NavigateExercise(state.currentExerciseIndex + 1),
                              );
                        } else {
                          context.read<LiveWorkoutBloc>().add(
                              CompleteWorkoutSession(widget.userId));
                        }
                      },
                      child: Text(state.currentExerciseIndex <
                              state.currentWorkout!.exercises.length - 1
                          ? 'Next Exercise'
                          : 'Finish Workout'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
