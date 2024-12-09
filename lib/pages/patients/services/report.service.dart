import 'package:voz_amiga/enum/result_type.dart';
import 'package:voz_amiga/pages/patients/dto/performance_report.dto.dart';
import 'package:voz_amiga/shared/client.dart';

class ReportService {
  static const _frag = 'reports';

  static Future<(String? error, PerformanceReport? data)> performance({
    required String patientId,
    required DateTime from,
    DateTime? until,
  }) async {
    final params = <String, String>{
      'patientId': patientId,
      'from': from.toString(),
      'until': until?.toString() ?? DateTime.now().toString(),
    };
    final response = await Api.get('$_frag/performance', params: params);

    if (response.type == ResultType.success) {
      return (
        null,
        PerformanceReport.fromJSON(response.value),
      );
    } else {
      return (
        response.value.toString(),
        null,
      );
    }
  }
}
