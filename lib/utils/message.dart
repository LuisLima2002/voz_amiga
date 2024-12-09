import 'package:voz_amiga/enum/result_type.dart';

class ApiResult {
  final dynamic value;
  ResultType type;

  ApiResult.success(this.value) : type = ResultType.success;

  ApiResult.error(this.value) : type = ResultType.error;
}
