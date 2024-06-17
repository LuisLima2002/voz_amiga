import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

class PatientsService {
  static const String _frag = 'patient';

  static Future<(dynamic, Paginated<PatientDTO>)> getPatients({
    String? filter,
    int? page,
    int? pageSize,
  }) async {
    final response = await ApiClient.get(_frag,
      params: {
        "filter": filter ?? "",
        "page": page.toString(),
        "pageSize": pageSize.toString(),
      }
      );
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
    return (jsonDecode(response.body),null);
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
      var response = await ApiClient.post(
      _frag,
      {
        "name": name,
        "birthdate":  DateFormat('dd/MM/yyyy').parse(birthdate).toIso8601String(),
        "emergencyContact": emergencyContact,
        "patientDocument":cpfPatient,
        "nameResponsible": nameResponsable,
        "responsibleDocument": responsibleDocument
      }
    );
      return response.statusCode;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }

static Future<int> update({
    required PatientDTO patient
  }) async {
    try {
      var response = await ApiClient.put(
      _frag,
      patient.toJson()
    );
      return response.statusCode;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }
  
  static Future<int> delete({
    required String id,
   }) async {
    final String uri = '$_frag/$id';
    final response = await ApiClient.delete(uri);
    
    return response.statusCode;
  }

}
