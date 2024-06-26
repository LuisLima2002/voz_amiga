import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:http/http.dart' as http;
import 'package:voz_amiga/dto/activity.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

class ActivitiesService {
  static const String _frag = 'activity';

  static Future<(dynamic, Paginated<ActivityDTO>)> getActivities({
    String? filter,
    int? page,
    int? pageSize,
  }) async {
    final params = <String, String>{
      'filter': filter ?? '',
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    final response = await ApiClient.get(_frag, params: params);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        null,
        Paginated.fromJson(
          response: body,
          parseList: (l) => l.map((d) => ActivityDTO.fromJSON(d)).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<ActivityDTO>.empty(),
      );
    }
  }

  static Future<int> save({
    required String title,
    required String description,
    required int points,
    required PlatformFile file,
  }) async {
    final uri = ApiClient.getUri(_frag);
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'title': title,
      'description': description,
      'points': '$points',
    });
    final multipartFile = await http.MultipartFile.fromPath(
      'media',
      file.path!,
      contentType: MediaType.parse(lookupMimeType(file.path!) ?? ""),
    );
    request.files.add(multipartFile);
    try {
      final response = await request.send();
      return response.statusCode;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<(dynamic, ActivityDTO?)> getActivity(String id) async {
    try {
      final response = await ApiClient.get('$_frag/$id');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print(body);
        return (null, ActivityDTO.fromJSON(body));
      }
      return ('Não encontrado', null);
    } catch (e) {
      print(e);
      return ('Falha ao se comunicar com o servidor', null);
    }
  }

  static Future delete(String id) async {
    try {
      await ApiClient.delete('$_frag/$id');
    } catch (e) {
      print(e);
      return 'Falha ao se comunicar com o servidor';
    }
  }

  static Future<int> update(
    String id, {
    required String title,
    required String description,
    required int points,
    required PlatformFile? file,
  }) async {
    final uri = ApiClient.getUri('$_frag/$id');
    var request = http.MultipartRequest('PUT', uri);
    print(uri);
    request.fields.addAll({
      'title': title,
      'description': description,
      'points': '$points',
    });
    if (file != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'media',
        file.path!,
        contentType: MediaType.parse(lookupMimeType(file.path!) ?? ""),
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
}
