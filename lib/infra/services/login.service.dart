import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:voz_amiga/core/login.service.dart';
import 'package:voz_amiga/dto/auth_response.dto.dart';
import 'package:voz_amiga/dto/result.dto.dart';
import 'package:voz_amiga/shared/client.dart';

class LoginService {
  final _path = 'auth';
  static const _storage = FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  Future<Result> login(String? user, String? password) async {
    var response = await ApiClient.post(
      _path,
      {
        'login': user,
        'password': password,
      },
    );
    var decoded = jsonDecode(response.body);

    var result = ResultWithBody<AuthResponseDTO>.parseJSON(
      decoded,
      (data) => AuthResponseDTO.fromJSON(data),
    );

    if (!result.hasErrors) {
      await _storage.write(key: 'jwt', value: result.content.token);
    }

    return ResultWithBody.of(true);
  }
}
