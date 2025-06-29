import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../../../models/responses/response_plant_model_wrapper_to_parse.dart';
import '../executor/get_plants_use_case.dart';

part 'generated/pico_rest_client.g.dart';

@RestApi()
abstract class PicoRestClient {

  factory PicoRestClient(Dio dio, {String? baseUrl}) = _PicoRestClient;

  @GET('/api/v1/GetPlants')
  @Headers(getPlantsUseCaseHeaders)
  Future<ResponsePlantModelWrapperToParse> getPlants(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
  );

}
