import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:voz_amiga/dto/frequencyReport.dto.dart';

import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PatientsService {
  static const String _frag = 'patient';
  static PagingController<int, PatientDTO> pagingController =
      PagingController(firstPageKey: 0);
  static Future<(dynamic, Paginated<PatientDTO>)> getPatients(
      {String? filter, int? page, int? pageSize, String? orderBy}) async {
    final response = await ApiClient.get(_frag, params: {
      "filter": filter ?? "",
      "page": page.toString(),
      "pageSize": pageSize.toString(),
      "orderBy": orderBy ?? ""
    });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        null,
        Paginated.fromJson(
          response: body,
          parseList: (l) => l.map(
            (d) {
              return PatientDTO.fromJSON(d);
            },
          ).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<PatientDTO>.empty(),
      );
    }
  }

  static Future<(dynamic, PatientDTO?)> getPatient(String patientId) async {
    final String uri = '$_frag/$patientId';
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (null, PatientDTO.fromJSON(body));
    } else {
      return (jsonDecode(response.body), null);
    }
  }

  static Future<(dynamic, FrequencyReportDTO?)> getFrequencyReport(
      String patientId, DateTime selectedMonth) async {
    final String uri = '$_frag/frequencyreport/$patientId';
    final response = await ApiClient.get(uri,
        params: {"selectedMonth": selectedMonth.toString()});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (null, FrequencyReportDTO.fromJSON(body));
    } else {
      return (jsonDecode(response.body), null);
    }
  }

  static Future<int> save({
    required String name,
    required String birthdate,
    required String emergencyContact,
    required String cpfPatient,
    required String nameResponsable,
    required String responsibleDocument,
  }) async {
    try {
      var response = await ApiClient.post(_frag, {
        "name": name,
        "birthdate":
            DateFormat('dd/MM/yyyy').parse(birthdate).toIso8601String(),
        "emergencyContact": emergencyContact,
        "patientDocument": cpfPatient,
        "nameResponsible": nameResponsable,
        "responsibleDocument": responsibleDocument
      });
      pagingController.refresh();
      return response.statusCode;
    } catch (e) {
      logger.e('at saving: $e');
      rethrow;
    }
  }

  static Future<int> update({required PatientDTO patient}) async {
    try {
      var response = await ApiClient.put(_frag, patient.toJson());
      pagingController.refresh();
      return response.statusCode;
    } catch (e) {
      logger.e('at saving: $e');
      rethrow;
    }
  }

  static Future<int> delete({
    required String id,
  }) async {
    final String uri = '$_frag/$id';
    final response = await ApiClient.delete(uri);
    pagingController.refresh();

    return response.statusCode;
  }
}
