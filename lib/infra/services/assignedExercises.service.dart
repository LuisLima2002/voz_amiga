import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:voz_amiga/dto/ActivityAttemptDTO.dto.dart';
import 'package:voz_amiga/dto/assignedExercise.dto.dart';
// import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

import 'package:http/http.dart' as http;

class AssignedExercisesService {
  // static Exercise? exercise;
  static const String _frag = 'assignedexercises';
  static String id = '';
  static const _storage = FlutterSecureStorage();

  static Future<(dynamic, Paginated<AssignedExerciseDTO>)>
      getExercises() async {
    final params = <String, String>{
      "token": await _storage.read(key: 'jwt') ?? "",
    };
    final response = await ApiClient.get(_frag, params: params);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        null,
        Paginated.fromJson(
          response: body,
          parseList: (l) =>
              l.map((d) => AssignedExerciseDTO.fromJSON(d)).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<AssignedExerciseDTO>.empty(),
      );
    }
  }

  static Future<(dynamic, List<ActivityAttemptDTO>?)> getActivityAttempts(
      String assignedExerciseId, String activityId) async {
    final String uri = '$_frag/attempt/$assignedExerciseId/$activityId';
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return (null, body.map((i) => ActivityAttemptDTO.fromJSON(i)).toList());
    } else {
      return (jsonDecode(response.body), List<ActivityAttemptDTO>.empty());
    }
  }

  static Future<(dynamic, AssignedExerciseDTO?)> getAssignedExercise(
      String id) async {
    final String uri = '$_frag/$id';
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (null, AssignedExerciseDTO.fromJSON(body));
    } else {
      return (jsonDecode(response.body), null);
    }
  }

  static Future<(dynamic, Paginated<AssignedExerciseDTO>)>
      getExercisesFromPatient(String patientId, String? filter, int? page,
          int? pageSize, String? orderBy) async {
    final params = <String, String>{
      // "patientId": patientId,
    };
    final response =
        await ApiClient.get('$_frag/frompatient/$patientId', params: params);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        null,
        Paginated.fromJson(
          response: body,
          parseList: (l) =>
              l.map((d) => AssignedExerciseDTO.fromJSON(d)).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<AssignedExerciseDTO>.empty(),
      );
    }
  }

  static Future<int> saveActivityAttempt(String id,
      {required String activityId,
      required XFile? file,
      bool done = false}) async {
    final uri = ApiClient.getUri('$_frag/attempt');

    var request = http.MultipartRequest('POST', uri);
    print(uri);
    request.fields.addAll({
      'assignedExerciseId': id,
      'activityId': activityId,
      'done': done.toString()
    });
    if (file != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(lookupMimeType(file.path) ?? ""),
      );
      request.files.add(multipartFile);
    }
    try {
      final response = await request.send();
      return response.statusCode;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<int> update(
      {required ActivityAttemptDTO activityAttempt}) async {
    try {
      var response =
          await ApiClient.put('$_frag/attempt', activityAttempt.toJson());
      return response.statusCode;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }
}
