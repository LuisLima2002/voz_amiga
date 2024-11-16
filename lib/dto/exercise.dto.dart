import 'package:voz_amiga/dto/activityOfExercise.dto.dart';

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
  final List<ActivityOfExerciseDTO> activities;

  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.activities,
  });

  Exercise.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        title = data['title'] ?? '',
        description = data['description'] ?? '',
        activities =
            data['activities'] != null ? parseActivies(data['activities']) : [],
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

List<ActivityOfExerciseDTO> parseActivies(List<dynamic> jsonActivies) {
  return jsonActivies
      .map<ActivityOfExerciseDTO>(
          (jsonActivity) => ActivityOfExerciseDTO.fromJSON(jsonActivity))
      .toList();
}
