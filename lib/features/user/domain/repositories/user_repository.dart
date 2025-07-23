
import 'package:workout_tracker/models/user_model.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> addUser(User user);
  Future<void> deleteUser(int userId);
}
