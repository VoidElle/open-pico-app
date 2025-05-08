import 'package:dio/dio.dart' hide Headers;
import 'package:open_pico_app/models/requests/request_login_model.dart';
import 'package:open_pico_app/network/usecases/login_usecase.dart';
import 'package:retrofit/retrofit.dart';

part 'login_rest_client.g.dart';

@RestApi()
abstract class LoginRestClient {

  factory LoginRestClient(Dio dio, {String? baseUrl}) = _LoginRestClient;

  @POST('/Login')
  @Headers(loginUseCaseHeaders)
  Future<dynamic> login(@Body() RequestLoginModel requestLoginModel);

}
