
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/models/exercise_model.dart';

class Workout extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final List<Exercise> exercises;
  final int order;

  const Workout({
    this.id,
    required this.userId,
    required this.name,
    this.exercises = const [],
    required this.order,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      name: map['name'],
      order: map['workout_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'workout_order': order,
    };
  }

  Workout copyWith({
    int? id,
    int? userId,
    String? name,
    List<Exercise>? exercises,
    int? order,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, exercises, order];
}
