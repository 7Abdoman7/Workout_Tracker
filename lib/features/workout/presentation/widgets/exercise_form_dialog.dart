
import 'package:flutter/material.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/set_model.dart';

class ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseFormDialog({super.key, this.exercise});

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _restMinutesController = TextEditingController();
  final TextEditingController _restSecondsController = TextEditingController();
  List<ExerciseSet> _sets = [];
  final Map<int, TextEditingController> _repsControllers = {};
  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, TextEditingController> _rpmControllers = {};
  final Map<int, TextEditingController> _rirControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _restMinutesController.text = widget.exercise!.restTimeMinutes.toString();
      _restSecondsController.text = widget.exercise!.restTimeSeconds.toString();
      _sets = List.from(widget.exercise!.sets);
    } else {
      _sets.add(const ExerciseSet(exerciseId: 0, setNumber: 1, reps: 0)); // Add an initial empty set
    }
    _initControllers();
  }

  void _initControllers() {
    for (var set in _sets) {
      _repsControllers[set.setNumber] = TextEditingController(text: set.reps.toString());
      _weightControllers[set.setNumber] = TextEditingController(text: set.weight?.toString() ?? '');
      _rpmControllers[set.setNumber] = TextEditingController(text: set.rpm?.toString() ?? '');
      _rirControllers[set.setNumber] = TextEditingController(text: set.rir?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _restMinutesController.dispose();
    _restSecondsController.dispose();
    _repsControllers.forEach((key, value) => value.dispose());
    _weightControllers.forEach((key, value) => value.dispose());
    _rpmControllers.forEach((key, value) => value.dispose());
    _rirControllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  void _addSet() {
    setState(() {
      final newSetNumber = _sets.length + 1;
      _sets.add(ExerciseSet(exerciseId: 0, setNumber: newSetNumber, reps: 0));
      _repsControllers[newSetNumber] = TextEditingController(text: '0');
      _weightControllers[newSetNumber] = TextEditingController(text: '');
      _rpmControllers[newSetNumber] = TextEditingController(text: '');
      _rirControllers[newSetNumber] = TextEditingController(text: '');
    });
  }

  void _removeSet(int index) {
    setState(() {
      final removedSetNumber = _sets[index].setNumber;
      _sets.removeAt(index);
      _repsControllers.remove(removedSetNumber);
      _weightControllers.remove(removedSetNumber);
      _rpmControllers.remove(removedSetNumber);
      _rirControllers.remove(removedSetNumber);

      // Re-number sets after removal and update controllers map
      for (int i = 0; i < _sets.length; i++) {
        final oldSetNumber = _sets[i].setNumber;
        final newSetNumber = i + 1;
        _sets[i] = _sets[i].copyWith(setNumber: newSetNumber);

        // Update controller keys
        if (oldSetNumber != newSetNumber) {
          _repsControllers[newSetNumber] = _repsControllers.remove(oldSetNumber)!;
          _weightControllers[newSetNumber] = _weightControllers.remove(oldSetNumber)!;
          _rpmControllers[newSetNumber] = _rpmControllers.remove(oldSetNumber)!;
          _rirControllers[newSetNumber] = _rirControllers.remove(oldSetNumber)!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Exercise Name'),
            ),
            TextField(
              controller: _restMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Rest Minutes'),
            ),
            TextField(
              controller: _restSecondsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Rest Seconds'),
            ),
            const SizedBox(height: 16),
            Text('Sets', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sets.length,
                itemBuilder: (context, index) {
                  final set = _sets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Set ${set.setNumber}'),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeSet(index),
                              ),
                            ],
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Reps'),
                            controller: _repsControllers[set.setNumber],
                            onChanged: (value) {
                              _sets[index] = set.copyWith(reps: int.tryParse(value) ?? 0);
                            },
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Weight (optional)'),
                            controller: _weightControllers[set.setNumber],
                            onChanged: (value) {
                              _sets[index] = set.copyWith(weight: double.tryParse(value));
                            },
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'RPM (optional)'),
                            controller: _rpmControllers[set.setNumber],
                            onChanged: (value) {
                              _sets[index] = set.copyWith(rpm: int.tryParse(value));
                            },
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'RIR (optional)'),
                            controller: _rirControllers[set.setNumber],
                            onChanged: (value) {
                              _sets[index] = set.copyWith(rir: int.tryParse(value));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addSet,
              child: const Text('Add Set'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text;
            final restMinutes = int.tryParse(_restMinutesController.text) ?? 0;
            final restSeconds = int.tryParse(_restSecondsController.text) ?? 0;

            if (name.isNotEmpty && _sets.isNotEmpty) {
              final newExercise = Exercise(
                id: widget.exercise?.id,
                workoutId: widget.exercise?.workoutId ?? 0, // Will be set by bloc
                userId: widget.exercise?.userId ?? 0, // Added userId
                name: name,
                sets: _sets,
                restTimeMinutes: restMinutes,
                restTimeSeconds: restSeconds,
                order: widget.exercise?.order ?? 0, // Will be set by bloc
              );
              Navigator.pop(context, newExercise);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
