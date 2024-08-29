import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _serverAdress = "localhost:5000";

  static Future<http.Response> post(String route, Object body) async {
    final uri = getUri(route);
    final json = jsonEncode(body);
    print(json);
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json,
    );

    return response;
  }

  static Future<http.Response> get(
    String route, {
    Map<String, String>? params,
  }) async {
    try {
      final response = await http.get(getUri(route, params: params));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> delete(String route) async {
    try {
      final response = await http.delete(getUri(route));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Uri getUri(
    String route, {
    Map<String, dynamic>? params,
  }) {
    return route.startsWith('http')
        ? Uri.parse(route)
        : Uri.http(_serverAdress, 'api/$route', params);
  }

  static Future<http.Response> put(String route, Object body) async {
    final uri = getUri(route);
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return response;
  }
}

class BypassCertificateOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
