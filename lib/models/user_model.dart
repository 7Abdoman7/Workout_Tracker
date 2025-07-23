
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String name;

  const User({this.id, required this.name});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
