import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:voz_amiga/core/login.service.dart';
import 'package:voz_amiga/dto/auth_response.dto.dart';
import 'package:voz_amiga/dto/result.dto.dart';
import 'package:voz_amiga/shared/client.dart';

class LoginService {
  static const _path = 'auth';
  static const _storage = FlutterSecureStorage();

  static Future<void> saiFora() async {
    await _storage.delete(key: 'jwt');
  }

  static Future<String?> get giveMyToken async {
    final token = await _storage.read(key: 'jwt');
    return token;
  }

  Future<LoginInfo> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt');
    final bool isPatient =
        bool.parse(await _storage.read(key: 'isPatient') ?? "false");
    return LoginInfo(token: token, isPatient: isPatient);
  }

  Future<ResultWithBody> login(String? user, String? password) async {
    var response = await ApiClient.post(
      _path,
      {
        'login': user,
        'password': password,
      },
    );
    var decoded = jsonDecode(response.body);

    var result = ResultWithBody<AuthResponseDTO>.fromJSON(
      decoded,
      (data) => AuthResponseDTO.fromJSON(data),
    );

    if (!result.hasErrors) {
      await _storage.write(key: 'jwt', value: result.content.token);
      await _storage.write(key: 'name', value: result.content.name);
      await _storage.write(
          key: 'isPatient', value: result.content.isPatient.toString());
    }
    return result;
  }
}

class LoginInfo {
  LoginInfo({required this.token, required this.isPatient});

  final String? token;
  final bool isPatient;
}
