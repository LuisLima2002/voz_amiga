import 'dart:core';
import 'dart:convert';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/enum/frequency_type.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';
import 'package:voz_amiga/utils/custom_http_client.dart';

class AssignActivityService {
  static const String _frag = 'asign/activity';

  static Future<(dynamic, Paginated<Exercise>)> getPatients({
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
          parseList: (l) => l.map((d) => Exercise.fromJSON(d)).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<Exercise>.empty(),
      );
    }
  }

  static Future<String> assign({
    required List<String> patientsIds,
    required String activityId,
    required int frequency,
    required FrequencyType frequencyType,
    required DateTime expectedConclusion,
  }) async {
    try {
      final response = await ApiClient.post(_frag, {
        'patientsIds': patientsIds,
        'activityId': activityId,
        'frequencyType': frequencyType.name,
        'expectedConclusion': expectedConclusion,
      });
      if (response.isSuccess) {
        return 'Ok';
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
