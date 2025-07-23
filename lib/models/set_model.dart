
import 'package:equatable/equatable.dart';

class ExerciseSet extends Equatable {
  final int? id;
  final int exerciseId;
  final int setNumber;
  final int reps;
  final double? weight;
  final int? rpm;
  final int? rir;

  const ExerciseSet({
    this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.rpm,
    this.rir,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'],
      exerciseId: map['exercise_id'],
      setNumber: map['set_number'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
      rpm: map['rpm'],
      rir: map['rir'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'rpm': rpm,
      'rir': rir,
    };
  }

  ExerciseSet copyWith({
    int? id,
    int? exerciseId,
    int? setNumber,
    int? reps,
    double? weight,
    int? rpm,
    int? rir,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpm: rpm ?? this.rpm,
      rir: rir ?? this.rir,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exerciseId,
        setNumber,
        reps,
        weight,
        rpm,
        rir,
      ];
}
