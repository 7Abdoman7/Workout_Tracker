

import 'package:workout_tracker/core/database/database_helper.dart';
import 'package:workout_tracker/features/user/domain/repositories/user_repository.dart';
import 'package:workout_tracker/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  @override
  Future<User> addUser(User user) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('users', user.toMap());
    return User(id: id, name: user.name);
  }

  @override
  Future<void> deleteUser(int userId) async {
    final db = await _databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  @override
  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }
}
