import 'package:voz_amiga/dto/assignedExercise.dto.dart';

class FrequencyReportDTO {
  final DateTime monthSelected;
  final List<AssignedExerciseFrequencyDTO> assignedActivitiesFrequency;

  const FrequencyReportDTO({
    required this.monthSelected,
    required this.assignedActivitiesFrequency,
  });

  factory FrequencyReportDTO.fromJSON(Map<String, dynamic> data) {
    return FrequencyReportDTO(
      monthSelected: DateTime.parse(data['monthSelected']),
      assignedActivitiesFrequency: (data['assignedActivitiesFrequency'] as List)
          .map((item) => AssignedExerciseFrequencyDTO.fromJSON(item))
          .toList(),
    );
  }
}

class AssignedExerciseFrequencyDTO {
  final AssignedExerciseDTO assignedExercise;
  final int expectedAttempts;
  final int doneAttempts;

  const AssignedExerciseFrequencyDTO(
      {required this.assignedExercise,
      required this.expectedAttempts,
      required this.doneAttempts});

  factory AssignedExerciseFrequencyDTO.fromJSON(Map<String, dynamic> data) {
    return AssignedExerciseFrequencyDTO(
      assignedExercise: AssignedExerciseDTO.fromJSON(data['assignedExercise']),
      expectedAttempts: data['expectedAttempts'] as int,
      doneAttempts: data['doneAttempts'] as int,
    );
  }
}
