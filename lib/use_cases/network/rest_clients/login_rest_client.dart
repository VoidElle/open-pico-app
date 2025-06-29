import 'package:dio/dio.dart' hide Headers;
import 'package:open_pico_app/models/requests/request_login_model.dart';
import 'package:open_pico_app/models/responses/response_user_model.dart';
import 'package:retrofit/retrofit.dart';

import '../executor/login_use_case.dart';

part 'generated/login_rest_client.g.dart';

@RestApi()
abstract class LoginRestClient {

  factory LoginRestClient(Dio dio, {String? baseUrl}) = _LoginRestClient;

  @POST('/apiTS/v2/Login')
  @Headers(loginUseCaseHeaders)
  Future<ResponseUserModel> login(
      @Header("Authorization") String authorization,
      @Body() RequestLoginModel requestLoginModel,
  );

}
