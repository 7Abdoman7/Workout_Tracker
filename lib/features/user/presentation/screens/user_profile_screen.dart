
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_state.dart';
import 'package:workout_tracker/models/user_model.dart';
import 'package:workout_tracker/features/workout/presentation/screens/workout_list_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profiles'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  title: Text(user.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutListScreen(userId: user.id!),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<UserBloc>().add(DeleteUser(user.id!));
                    },
                  ),
                );
              },
            );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No users found.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
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
                  context.read<UserBloc>().add(AddUser(User(name: name)));
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
}
