import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/pages/patients/services/report.service.dart';
import 'package:voz_amiga/utils/custom_http_client.dart';
import 'package:voz_amiga/utils/message.dart';

class ApiClient {
  static const String _serverAdress = "192.168.0.6:5000";

  static Future<http.Response> post(
    String route,
    Object body, {
    Map<String, dynamic>? files,
  }) async {
    //
    if (files != null && files.isNotEmpty == true) {
      return _postWithFiles(route, body, files);
    } else {
      return _post(route, body);
    }
  }

  static Future<http.Response> _postWithFiles(
    String route,
    Object body,
    Map<String, dynamic> files,
  ) async {
    final uri = getUri(route);
    var request = http.MultipartRequest('POST', uri);

    for (var e in files.entries) {
      late http.MultipartFile multipartFile;
      if (e.value is String) {
        multipartFile = await http.MultipartFile.fromPath(
          e.key,
          e.value,
          contentType: MediaType.parse(
            lookupMimeType(e.value) ?? "application/octet-stream",
          ),
        );
      } else if (e.value is File) {
        multipartFile = await http.MultipartFile.fromPath(
          e.key,
          (e.value as File).path,
          contentType: MediaType.parse(
            lookupMimeType((e.value as File).path) ??
                "application/octet-stream",
          ),
        );
      } else if (e.value is List<int>) {
        multipartFile = http.MultipartFile.fromBytes(
          e.key,
          e.value,
          contentType: MediaType.parse(
            lookupMimeType((e.value as File).path) ??
                "application/octet-stream",
          ),
        );
      } else {
        throw Exception("Unexpected data type!");
      }
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final parseResponse = await http.Response.fromStream(response);
      logger.t(
        'Request to "$route" wiht $request\nwith response ${parseResponse.body}',
      );
      return jsonDecode(parseResponse.body);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  static Future<http.Response> _post(
    String route,
    Object body,
  ) async {
    //
    final uri = getUri(route);
    final json = jsonEncode(body);
    logger.t(json);

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json,
    );

    return response;
  }

  static Future<http.Response> put(String route, Object? body) async {
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

  static Future<http.Response> get(
    String route, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = getUri(route, params: params);
      final response = await http.get(uri);
      logger.t(
        'Request to:\n $uri\nwith reponse: [${response.statusCode}] ${response.body}',
      );
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
}

class BypassCertificateOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Api {
  static const String _serverAdress = "192.168.0.6:5000";

  static Future<ApiResult> post(
    String route,
    Object body, {
    Map<String, dynamic>? files,
  }) async {
    http.Response response;
    final uri = getUri(route);
    if (files != null && files.isNotEmpty == true) {
      response = await _postWithFiles(uri, body, files);
    } else {
      response = await _post(uri, body);
    }
    final result = _toResult(response);
    logger.t(
      'Request to:\n [POST] $uri\nof $body \nwith reponse:\n[${response.statusCode}] ${result.value}',
    );
    return result;
  }

  static Future<http.Response> _postWithFiles(
    Uri uri,
    Object body,
    Map<String, dynamic> files,
  ) async {
    var request = http.MultipartRequest('POST', uri);

    for (var e in files.entries) {
      late http.MultipartFile multipartFile;
      if (e.value is String) {
        multipartFile = await http.MultipartFile.fromPath(
          e.key,
          e.value,
          contentType: MediaType.parse(
            lookupMimeType(e.value) ?? "application/octet-stream",
          ),
        );
      } else if (e.value is File) {
        multipartFile = await http.MultipartFile.fromPath(
          e.key,
          (e.value as File).path,
          contentType: MediaType.parse(
            lookupMimeType((e.value as File).path) ??
                "application/octet-stream",
          ),
        );
      } else if (e.value is List<int>) {
        multipartFile = http.MultipartFile.fromBytes(
          e.key,
          e.value,
          contentType: MediaType.parse(
            lookupMimeType((e.value as File).path) ??
                "application/octet-stream",
          ),
        );
      } else {
        throw Exception("Unexpected data type!");
      }
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final parseResponse = await http.Response.fromStream(response);
      return parseResponse;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  static Future<http.Response> _post(
    Uri uri,
    Object body,
  ) async {
    final json = jsonEncode(body);
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json,
    );

    return response;
  }

  static Future<ApiResult> put(String route, Object? body) async {
    final uri = getUri(route);
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    final result = _toResult(response);
    logger.t(
      'Request to:\n [PUT] $uri\nwith reponse:\n[${response.statusCode}] ${result.value}',
    );
    return result;
  }

  static Future<ApiResult> get(
    String route, {
    Map<String, String?>? params,
  }) async {
    try {
      final uri = getUri(route, params: params);
      final response = await http.get(uri);
      final result = _toResult(response);
      logger.t(
        'Request to:\n [GET] $uri\nwith reponse:\n[${response.statusCode}] ${result.value}',
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<ApiResult> delete(String route) async {
    try {
      final uri = getUri(route);
      final response = await http.delete(uri);
      final result = _toResult(response);
      logger.t(
        'Request to:\n [DELETE] $uri\nwith reponse:\n[${response.statusCode}] ${result.value}',
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Uri getUri(
    String route, {
    Map<String, dynamic>? params,
  }) {
    params?.removeWhere((String k, dynamic v) {
      return v == null;
    });
    return route.startsWith('http')
        ? Uri.parse(route)
        : Uri.http(_serverAdress, 'api/$route', params);
  }

  static ApiResult _toResult(http.Response response) {
    try {
      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : "";

      return response.isSuccess
          ? ApiResult.success(responseBody)
          : ApiResult.error(responseBody);
    } catch (e) {
      logger.e(e);
      return ApiResult.error(response.body);
    }
  }
}
