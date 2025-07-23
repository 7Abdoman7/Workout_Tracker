
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserEvent {}

class AddUser extends UserEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUser extends UserEvent {
  final int userId;

  const DeleteUser(this.userId);

  @override
  List<Object> get props => [userId];
}
