class ExerciseActivity {
  final String id;
  final String name;

  ExerciseActivity.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        name = data['name'] ?? '';
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final int points;
  final List<ExerciseActivity>? activities;

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
        activities = _handleList(data['activities']),
        points = data['points'] ?? 0;

  static _handleList(dynamic data) {
    if (data == null || data is! List) return null;

    return data.map((a) => ExerciseActivity.fromJSON(a)).toList();
  }

  @override
  String toString() {
    return '[${super.toString()}]: $id, $title, $points';
  }
}
