class ActivityOfExerciseDTO {
  final String id;
  final String name;

  const ActivityOfExerciseDTO({
    required this.id,
    required this.name
  });

  ActivityOfExerciseDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        name = data['name'] ?? "";
        
  @override
  String toString() {
    return '[${super.toString()}]: $id-$name';
  }
}
