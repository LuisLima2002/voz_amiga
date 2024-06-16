import 'package:flutter/material.dart';

class ResultWithBody<T> extends Result {
  late T? _content;

  @override
  ResultWithBody.parseJSON(
    dynamic data,
    T Function(Map<String, dynamic> data) bodyParser,
  ) : super.parseJSON(data) {
    try {
      if (data['messages'] == null) {
        _content = bodyParser(data);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  T get content {
    if (_content != null) return _content!;
    throw Exception("Invalid access of result with error");
  }

  ResultWithBody.of(T data) : super.parseJSON({}) {
    _content = data;
  }
}

class Result {
  @protected
  late List<String>? _errors;

  Result.parseJSON(dynamic data) {
    try {
      if (data['messages'] != null) {
        _errors = (data['messages'] as List<dynamic>)
            .map<String>((v) => "$v")
            .toList();
      } else {
        _errors = null;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
  List<String> get errors {
    if (_errors != null) return _errors!;
    throw Exception("Invalid access of result with error");
  }

  bool get hasErrors {
    return _errors?.isNotEmpty == true;
  }
}
