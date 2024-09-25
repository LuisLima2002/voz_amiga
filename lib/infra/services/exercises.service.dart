import 'dart:convert';
import 'package:voz_amiga/dto/exercise.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

class ExercisesService {
  static const String _frag = 'exercises';

  static Future<(dynamic, Paginated<Exercise>)> getExercises({
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

  static Future<String> save({
    required String title,
    required String description,
    required int points,
  }) async {
    try {
      final response = await ApiClient.post(_frag, {
        'title': title,
        'description': description,
        'points': points,
      });
      String newExerciseId = jsonDecode(response.body)['id'];
      return newExerciseId;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<(dynamic, Exercise?)> getExercise(String id) async {
    try {
      final response = await ApiClient.get('$_frag/$id');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print(body);
        return (null, Exercise.fromJSON(body));
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

  static Future<String> update(
    String id, {
    required String title,
    required String description,
    required int points,
  }) async {
    try {
      final response = await ApiClient.put('$_frag/$id', {
        'title': title,
        'description': description,
        'points': points,
      });
      return jsonDecode(response.body)['id'];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> addActivityToExercise({
    required String exerciseId,
    required String activityId,
  }) async {
    //
    try {
      final response = await ApiClient.put('$_frag/$exerciseId/activity', {
        'exerciseId': exerciseId,
        'activityId': activityId,
        'status': true,
      });
      return jsonDecode(response.body)['message'];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future removeActivityFromService({
    required String exerciseId,
    required String activityId,
  }) async {
    try {
      final response = await ApiClient.put('$_frag/$exerciseId/activity', {
        'exerciseId': exerciseId,
        'activityId': activityId,
        'status': false,
      });
      return jsonDecode(response.body)['message'];
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
