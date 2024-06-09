import 'dart:convert';

import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/shared/client.dart';

class ActivitiesService {
  static const String _frag = 'activity';

  static Future<(dynamic, List<ActivityDTO>)> getActivities() async {
    final response = await ApiClient.get(_frag);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return (
        null,
        (body).map((d) => ActivityDTO.fromJSON(d)).toList(),
      );
    } else {
      return (jsonDecode(response.body), <ActivityDTO>[]);
    }
  }

  // static Future<void> postMultipart(File imageFile) async {
  //   final Ur
  //   var request = http.MultipartRequest('POST', Uri.parse(url));
  //   request.files.add(await http.MultipartFile.fromPath('file', file.path));

  //   var response = await request.send();
  //   if (response.statusCode == 200) {
  //     // Upload successful
  //   } else {
  //     // Handle error
  //   }
  // }

  // static Future<ResultWithBody<ActivityDTO>> save() async {
  //   final response = await ApiClient.post(_frag, {

  //   })

  //   return ResultWithBody.of(true);
  // }
}
