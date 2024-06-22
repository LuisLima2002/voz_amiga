import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:voz_amiga/dto/professional.dto.dart';
import 'package:voz_amiga/shared/client.dart';
import 'package:voz_amiga/utils/paginated.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProfessionalsService {
  static const String _frag = 'profissional';
  static const _storage = FlutterSecureStorage();
  static PagingController<int, ProfessionalDTO> pagingController =
      PagingController(firstPageKey: 0);
  static Future<(dynamic, Paginated<ProfessionalDTO>)> getProfessionals({
    String? filter,
    int? page,
    int? pageSize,
  }) async {
    final response = await ApiClient.get(_frag, params: {
      "filter": filter ?? "",
      "page": page.toString(),
      "pageSize": pageSize.toString(),
    });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        null,
        Paginated.fromJson(
          response: body,
          parseList: (l) => l.map(
            (d) {
              return ProfessionalDTO.fromJSON(d);
            },
          ).toList(),
        ),
      );
    } else {
      return (
        jsonDecode(response.body),
        Paginated<ProfessionalDTO>.empty(),
      );
    }
  }

  static Future<(dynamic, ProfessionalDTO?)> getProfessional(
      String professionalId) async {
    final String uri = '$_frag/$professionalId';
    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (null, ProfessionalDTO.fromJSON(body));
    } else {
      return (jsonDecode(response.body), null);
    }
  }

  static Future<String?> save({
    required String name,
    required String email,
  }) async {
    try {
      var response = await ApiClient.post(
      _frag,
      {
        "name": name,
        "email": email
      }
    );
        pagingController.refresh();
      return response.body;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }

static  Future<Response>  changePassword({
    required String password,
    required String newPassword
  }) async {
    try {
      var response = await ApiClient.put(
      "$_frag/changepassword",
      {
        "token": await _storage.read(key: 'jwt'),
        "password":password,
        "newPassword":newPassword
      }
    );
      return response;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }

static Future<int> update({
    required ProfessionalDTO patient
  }) async {
    try {
      var response = await ApiClient.put(
      _frag,
      patient.toJson()
    );
      pagingController.refresh();
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
    pagingController.refresh();

    return response.statusCode;
  }

  static Future<String> resetPassword({required String id}) async {
    try {
      var response = await ApiClient.put('$_frag/resetpassword/$id', null);
      if (response.statusCode != 200) throw Error();
      return response.body;
    } catch (e) {
      print('at saving: $e');
      rethrow;
    }
  }
}
