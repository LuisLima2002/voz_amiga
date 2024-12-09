import 'package:intl/intl.dart';

class ActivityAttemptDTO {
  final String id;
  final DateTime createAt;
  final String comment;
  final int rating;

  const ActivityAttemptDTO(
      {required this.id,
      required this.createAt,
      required this.comment,
      required this.rating});

  ActivityAttemptDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        createAt = data['createAt'] != null
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(data['createAt'])
            : DateTime.now(),
        comment = data['comment'] ?? '',
        rating = data['rating'] ?? 0;
  @override
  String toString() {
    return '[${super.toString()}]: $id';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createAt': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(createAt),
      'comment': comment,
      'rating': rating
    };
  }
}
