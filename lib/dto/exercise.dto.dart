class Exercise {
  final String id;
  final String title;
  final String description;
  final int points;
  final List<String>? activities;

  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.activities,
  });

  Exercise.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        title = data['title'] ?? '',
        description = data['description'] ?? '',
        activities = data['activities'] ?? [],
        points = data['points'] ?? 0;
  @override
  String toString() {
    return '[${super.toString()}]: $id, $title, $points';
  }
}
