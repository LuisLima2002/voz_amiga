import 'package:intl/intl.dart';
import 'package:voz_amiga/dto/exercise.dto.dart';

class AssignedExerciseDTO {
  final String id;
  final String assignedAt;
  final DateTime expectedConclusion;
  final DateTime? lastAttemptAt;
  final int frequency;
  final int frequencyType;
  final Exercise exercise;
  final int status;

  const AssignedExerciseDTO(
      {required this.id,
      required this.assignedAt,
      required this.expectedConclusion,
      this.lastAttemptAt,
      required this.frequency,
      required this.frequencyType,
      required this.exercise,
      required this.status});

  AssignedExerciseDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        assignedAt = data['assignedAt'] ?? DateTime.now(),
        expectedConclusion = data['expectedConclusion'] != null
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .parse(data['expectedConclusion'])
            : DateTime.now(),
        lastAttemptAt = data['lastAttemptAt'] != null
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .parse(data['expectedConclusion'])
            : null,
        frequency = data['frequency'] ?? 0,
        frequencyType = data['frequencyType'] ?? 0,
        exercise = Exercise.fromJSON(data['exercise']),
        status = data['status'] ?? 0;
  @override
  String toString() {
    return '[${super.toString()}]: $id';
  }
}
