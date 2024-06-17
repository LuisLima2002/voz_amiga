import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _serverAdress = "192.168.0.6:5001";

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

  static Future<http.Response> get(
    String route, {
    Map<String, String>? params,
  }) async {
    try {
      if (params != null && params.length > 1) {
        var paramsString = params.entries
            .map(
              (p) => '&${p.key}=${p.value}',
            )
            .join("&");
        route += '?$paramsString';
      }
      final response = await http.get(_getUri(route));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Uri _getUri(String route) {
    return route.startsWith('http')
        ? Uri.parse(route)
        : Uri.https(_serverAdress, 'api/$route');
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
