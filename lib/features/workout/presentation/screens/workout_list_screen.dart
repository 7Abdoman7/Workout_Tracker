
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_event.dart';
import 'package:workout_tracker/features/workout/presentation/bloc/workout_state.dart';
import 'package:workout_tracker/models/workout_model.dart';
import 'package:workout_tracker/features/workout/presentation/screens/workout_detail_screen.dart';
import 'package:workout_tracker/features/history/presentation/screens/workout_history_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  final int userId;

  const WorkoutListScreen({super.key, required this.userId});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(LoadWorkouts(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutHistoryScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutLoaded) {
            return ReorderableListView.builder(
              itemCount: state.workouts.length,
              itemBuilder: (context, index) {
                final workout = state.workouts[index];
                return Dismissible(
                  key: ValueKey(workout.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context
                        .read<WorkoutBloc>()
                        .add(DeleteWorkout(workout.id!, widget.userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${workout.name} dismissed')),
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
                      title: Text(workout.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailScreen(
                              userId: widget.userId,
                              workout: workout,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditWorkoutDialog(context, workout);
                        },
                      ),
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                context
                    .read<WorkoutBloc>()
                    .add(ReorderWorkouts(widget.userId, oldIndex, newIndex));
              },
            );
          } else if (state is WorkoutError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No workouts found.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Workout'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter workout name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  context.read<WorkoutBloc>().add(AddWorkout(
                        Workout(
                          userId: widget.userId,
                          name: name,
                          order: 0, // Order will be handled by reorder logic
                        ),
                      ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditWorkoutDialog(BuildContext context, Workout workout) {
    final TextEditingController nameController =
        TextEditingController(text: workout.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Workout'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter workout name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  context.read<WorkoutBloc>().add(UpdateWorkout(
                        workout.copyWith(name: name),
                      ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
