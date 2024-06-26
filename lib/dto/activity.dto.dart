class ActivityDTO {
  final String id;
  final String title;
  final String description;
  final String mimeType;
  final String data;
  final int points;

  const ActivityDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.data,
    required this.mimeType,
    required this.points,
  });

  ActivityDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        title = data['title'] ?? '',
        description = data['description'] ?? '',
        data = data['data'] ?? '',
        mimeType = data['mimeType'] ?? '',
        points = data['points'] ?? 0;
  @override
  String toString() {
    return '[${super.toString()}]: $id, $title, $data, $mimeType, $points';
  }
}
