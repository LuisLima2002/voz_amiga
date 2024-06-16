import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import 'package:http/http.dart' as http;
import 'package:voz_amiga/dto/patient.dto.dart';
import 'package:voz_amiga/dto/result.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';

class PatientsService {
  static const String _frag = 'patient';

  static Future<(dynamic, Paginated<PatientDTO>)> getPatients({
    String? filter,
    int? page,
    int? pageSize,
  }) async {
    final response = await ApiClient.get(_frag);
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
}
