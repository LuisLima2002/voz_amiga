import 'package:http/http.dart';
import 'package:voz_amiga/infra/services/login.service.dart';

class CustomHttpClient extends BaseClient {
  static Future<Map<String, String>> _getHeaders() async {
    return <String, String>{
      'Authorization': await LoginService.giveMyToken ?? '',
    };
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers.addAll(await _getHeaders());
    return request.send();
  }
}
