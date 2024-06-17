import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _serverAdress = "localhost:5001";

  static Future<http.Response> post(String route, Object body) async {
    final uri = _getUri(route);
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  static Future<http.Response> put(String route, Object body) async {
    final uri = _getUri(route);
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  static Future<http.Response> get(
    String route, {
    Map<String, String>? params,
  }) async {
    try {
      final response = await http.get(_getUri(route,params));
      return response;
    } catch (e) {
      rethrow;
    }
  }

   static Future<http.Response> delete(
    String route, {
    Map<String, String>? params,
  }) async {
    try {
      final response = await http.delete(_getUri(route,params));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Uri _getUri(String route,[ Map<String,dynamic>? param]) {
    return route.startsWith('http')
        ? Uri.parse(route)
        : Uri.https(_serverAdress, 'api/$route',param);
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
