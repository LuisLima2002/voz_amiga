class ActivityDTO {
  final String id;
  final String title;
  final String description;
  final String mimeType;
  final String data;

  const ActivityDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.data,
    required this.mimeType,
  });

  ActivityDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        description = data['description'],
        data = data['data'],
        mimeType = data['mimeType'];
}
