
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/features/user/domain/repositories/user_repository.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:workout_tracker/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<DeleteUser>(_onDeleteUser);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await userRepository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onAddUser(AddUser event, Emitter<UserState> emit) async {
    try {
      final newUser = await userRepository.addUser(event.user);
      final users = await userRepository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      await userRepository.deleteUser(event.userId);
      final users = await userRepository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
