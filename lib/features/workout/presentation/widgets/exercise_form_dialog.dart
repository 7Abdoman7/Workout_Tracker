import 'package:flutter/material.dart';
import 'package:workout_tracker/models/exercise_model.dart';
import 'package:workout_tracker/models/set_model.dart';

class ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;
  final int userId;
  final int workoutId;

  const ExerciseFormDialog({
    super.key,
    this.exercise,
    required this.userId,
    required this.workoutId,
  });

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
      _sets.add(const ExerciseSet(exerciseId: 0, setNumber: 1, reps: 0));
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
    if (_sets.length <= 1) return; // Don't remove the last set

    setState(() {
      final removedSetNumber = _sets[index].setNumber;
      _sets.removeAt(index);
      _repsControllers[removedSetNumber]?.dispose();
      _weightControllers[removedSetNumber]?.dispose();
      _rpmControllers[removedSetNumber]?.dispose();
      _rirControllers[removedSetNumber]?.dispose();
      _repsControllers.remove(removedSetNumber);
      _weightControllers.remove(removedSetNumber);
      _rpmControllers.remove(removedSetNumber);
      _rirControllers.remove(removedSetNumber);

      // Re-number sets after removal and update controllers map
      final Map<int, TextEditingController> newRepsControllers = {};
      final Map<int, TextEditingController> newWeightControllers = {};
      final Map<int, TextEditingController> newRpmControllers = {};
      final Map<int, TextEditingController> newRirControllers = {};

      for (int i = 0; i < _sets.length; i++) {
        final oldSetNumber = _sets[i].setNumber;
        final newSetNumber = i + 1;
        _sets[i] = _sets[i].copyWith(setNumber: newSetNumber);

        // Move controllers to new map with correct keys
        newRepsControllers[newSetNumber] = _repsControllers[oldSetNumber]!;
        newWeightControllers[newSetNumber] = _weightControllers[oldSetNumber]!;
        newRpmControllers[newSetNumber] = _rpmControllers[oldSetNumber]!;
        newRirControllers[newSetNumber] = _rirControllers[oldSetNumber]!;
      }

      _repsControllers.clear();
      _weightControllers.clear();
      _rpmControllers.clear();
      _rirControllers.clear();
      _repsControllers.addAll(newRepsControllers);
      _weightControllers.addAll(newWeightControllers);
      _rpmControllers.addAll(newRpmControllers);
      _rirControllers.addAll(newRirControllers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exercise == null ? 'Add Exercise' : 'Edit Exercise',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _restMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rest Minutes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _restSecondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rest Seconds',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sets', style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sets.length,
                itemBuilder: (context, index) {
                  final set = _sets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Set ${set.setNumber}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (_sets.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSet(index),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Reps',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  controller: _repsControllers[set.setNumber],
                                  onChanged: (value) {
                                    _sets[index] = set.copyWith(reps: int.tryParse(value) ?? 0);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  controller: _weightControllers[set.setNumber],
                                  onChanged: (value) {
                                    _sets[index] = set.copyWith(weight: double.tryParse(value));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'RPM',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  controller: _rpmControllers[set.setNumber],
                                  onChanged: (value) {
                                    _sets[index] = set.copyWith(rpm: int.tryParse(value));
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'RIR',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  controller: _rirControllers[set.setNumber],
                                  onChanged: (value) {
                                    _sets[index] = set.copyWith(rir: int.tryParse(value));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final restMinutes = int.tryParse(_restMinutesController.text) ?? 0;
                    final restSeconds = int.tryParse(_restSecondsController.text) ?? 0;

                    if (name.isNotEmpty && _sets.isNotEmpty) {
                      final newExercise = Exercise(
                        id: widget.exercise?.id,
                        workoutId: widget.workoutId,
                        userId: widget.userId,
                        name: name,
                        sets: _sets,
                        restTimeMinutes: restMinutes,
                        restTimeSeconds: restSeconds,
                        order: widget.exercise?.order ?? 0,
                      );
                      Navigator.pop(context, newExercise);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an exercise name and at least one set'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}