import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../use_cases/get_plants_use_case.dart';

part 'pico_rest_client.g.dart';

@RestApi()
abstract class PicoRestClient {

  factory PicoRestClient(Dio dio, {String? baseUrl}) = _PicoRestClient;

  @GET('/api/v1/GetPlants')
  @Headers(getPlantsUseCaseHeaders)
  Future<dynamic> getPlants(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
  );

}
