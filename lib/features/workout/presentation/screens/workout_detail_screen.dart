
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_event.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_state.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/workout_model.dart';
import 'package:workout_tracker/features/live_workout/presentation/screens/live_workout_screen.dart';
import 'package:workout_tracker/features/workout/presentation/widgets/exercise_form_dialog.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int userId;
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.userId,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(LoadWorkouts(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutLoaded) {
            final currentWorkout = state.workouts.firstWhere(
                (w) => w.id == widget.workout.id,
                orElse: () => widget.workout);
            return ReorderableListView.builder(
              itemCount: currentWorkout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = currentWorkout.exercises[index];
                return Dismissible(
                  key: ValueKey(exercise.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context.read<WorkoutBloc>().add(
                        DeleteExercise(exercise.id!, widget.workout.id!, widget.userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${exercise.name} dismissed')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                          'Sets: ${exercise.sets.length}, Rest: ${exercise.restTimeMinutes}m ${exercise.restTimeSeconds}s'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showAddEditExerciseDialog(context, exercise);
                        },
                      ),
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                context.read<WorkoutBloc>().add(ReorderExercises(
                    widget.workout.id!,
                    oldIndex,
                    newIndex > oldIndex ? newIndex - 1 : newIndex));
              },
            );
          } else if (state is WorkoutError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No exercises found.'));
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addExercise",
            onPressed: () => _showAddEditExerciseDialog(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "startWorkout",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveWorkoutScreen(
                    workout: widget.workout,
                    userId: widget.userId,
                  ),
                ),
              );
            },
            label: const Text('Start Workout'),
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

// Update the _showAddEditExerciseDialog method in WorkoutDetailScreen

  void _showAddEditExerciseDialog(BuildContext context, [Exercise? exercise]) async {
    final workoutBloc = context.read<WorkoutBloc>(); // Get bloc before await

    final newExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => ExerciseFormDialog(
        exercise: exercise,
        userId: widget.userId,
        workoutId: widget.workout.id!,
      ),
    );

    if (newExercise != null) {
      if (!mounted) return; // Check mounted after await

      if (exercise == null) {
        workoutBloc.add(AddExercise(
          newExercise,
          widget.userId,
        ));
      } else {
        workoutBloc.add(UpdateExercise(
          newExercise.copyWith(id: exercise.id),
          widget.userId,
        ));
      }
    }
  }
}
