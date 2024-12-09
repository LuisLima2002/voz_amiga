class AssignmentData {
  int frequency;
  String frequencyType;
  DateTime expectedConclusion;
  late List<String> patientsIds;

  AssignmentData({
    required this.frequency,
    required this.frequencyType,
    required this.expectedConclusion,
  });

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'frequencyType': frequencyType,
      'expectedConclusion': expectedConclusion.toIso8601String(),
      'patientsIds': patientsIds,
    };
  }
}
