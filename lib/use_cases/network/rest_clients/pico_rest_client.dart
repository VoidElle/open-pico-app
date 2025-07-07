import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../../../models/requests/request_command_model.dart';
import '../../../models/responses/common_response_wrapper.dart';
import '../../../models/responses/device_status_response.dart';
import '../../../utils/constants/headers_constants.dart';

part 'generated/pico_rest_client.g.dart';

@RestApi()
abstract class PicoRestClient {

  factory PicoRestClient(Dio dio, {String? baseUrl}) = _PicoRestClient;

  @GET('/api/v1/GetPlants')
  @Headers(HeadersConstants.commonHeaders)
  Future<CommonResponseWrapper> getPlants(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
  );

  @GET('/api/v1/GetPICOState')
  @Headers(HeadersConstants.commonHeaders)
  Future<DeviceStatusResponse> getPicoState(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
      @Query("picoSerial") String picoSerial,
      @Query("PIN") String pin,
  );

  @POST('/api/v1/SendPicoCmd')
  @Headers(HeadersConstants.commonWithJsonRequestHeaders)
  Future<CommonResponseWrapper> executeCommand(
      @Header("Token") String token,
      @Header("Authorization") String authorization,
      @Query("picoSerial") String picoSerial,
      @Query("PIN") String pin,
      @Body() RequestCommandModel requestCommandModel,
  );

}
