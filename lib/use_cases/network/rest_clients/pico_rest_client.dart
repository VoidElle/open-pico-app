import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../../../models/responses/common_response_wrapper.dart';
import '../../../models/responses/device_status_response.dart';
import '../executor/get_plants_use_case.dart';

part 'generated/pico_rest_client.g.dart';

@RestApi()
abstract class PicoRestClient {

  factory PicoRestClient(Dio dio, {String? baseUrl}) = _PicoRestClient;

  @GET('/api/v1/GetPlants')
  @Headers(commonHeaders)
  Future<CommonResponseWrapper> getPlants(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
  );

  @GET('/api/v1/GetPICOState')
  @Headers(commonHeaders)
  Future<DeviceStatusResponse> getPicoState(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
      @Query("picoSerial") String picoSerial,
      @Query("PIN") String pin,
  );

}
