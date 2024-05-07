import 'dart:convert';

import 'package:http/http.dart' as http;

class ClientHttp {
  final String _serverAdress = "";

  Future<http.Response> post(String endPoint, Object body,
      Map<String, dynamic>? queryParameters) async {
    final response = await http.post(
      Uri.https(_serverAdress, endPoint, queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> get(String endPoint) async {
    final response = await http.get(Uri.https(_serverAdress, endPoint));
    return response;
  }
}
