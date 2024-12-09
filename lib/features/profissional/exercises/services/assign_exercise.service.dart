import 'package:voz_amiga/enum/result_type.dart';
import 'package:voz_amiga/features/profissional/exercises/models/assignment_data.dart';
import 'package:voz_amiga/features/profissional/exercises/models/patient.model.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

class AssignExerciseService {
  ///
  static Future<(String? error, Paginated<Patient>?)> getPatients({
    required String exerciseId,
    String? filter,
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final params = <String, String?>{
      'filter': filter ?? '',
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'status': status,
    };
    final result = await Api.get(
      'assign/$exerciseId/unasigned-patients',
      params: params,
    );
    if (result.type == ResultType.success) {
      return (
        null,
        Paginated.fromJson(
          response: result.value,
          parseList: (l) => l.map((d) => Patient.fromJSON(d)).toList(),
        ),
      );
    }
    return (
      result.value.toString(),
      null,
    );
  }

  static Future<String?> assign(String exerciseId, AssignmentData data) async {
    final result = await Api.post('assign/exercise', {
      'exerciseId': exerciseId,
      ...data.toMap(),
    });
    return result.type == ResultType.success ? null : result.value.toString();
  }
}
