import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/models/responses/response_plant_model_wrapper_parsed.dart';
import 'package:open_pico_app/models/responses/zona_model.dart';

import '../../models/responses/device_status_response.dart';
import '../../models/responses/response_plant_model.dart';
import '../../models/responses/common_response_wrapper.dart';
import '../../providers/global/global_providers.dart';
import '../../providers/global/global_rest_client_providers.dart';
import '../../use_cases/network/core/network_handler.dart';
import '../aes_crypt.dart';
import '../constants/headers_constants.dart';
import '../constants/network_constants.dart';
import 'package:open_pico_app/providers/global/aes_crypt_provider.dart';

class PlantsResponsesParser {

  // This method retrieves plants data and parses it into a structured format
  static Future<ResponsePlantModelWrapperParsed> retrievePlantsParsed(WidgetRef ref) async {

    // Retrieve the new token from the AES crypt provider
    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    // Retrieve the current user's email from the global user email provider
    final String? currentEmail = ref.read(globalUserEmailProvider);

    // Retrieve the API key using the current email
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);

    // Fetch the plants data from the REST client using the new token and authorization header
    final CommonResponseWrapper responsePlantModelWrapperToParse =
      await ref.read(picoRestClientProvider).getPlants(newToken, authorization);

    // Retrieve the response description from the parsed response
    final String jsonToParse = responsePlantModelWrapperToParse.resDescr;

    // Decode the JSON string into a list of dynamic objects
    final List<dynamic> responsePlantModelListToParse = jsonDecode(jsonToParse)
        .map((e) => ResponsePlantModel.fromJson(e))
        .toList();

    // Parse the list of dynamic objects into a list of ResponsePlantModel
    final List<ResponsePlantModel> parsedPlants = <ResponsePlantModel>[];
    for (final dynamic plant in responsePlantModelListToParse) {
      if (plant is ResponsePlantModel) {
        parsedPlants.add(plant);
      }
    }

    // Wrap the parsed plants into a ResponsePlantModelWrapperParsed object
    final ResponsePlantModelWrapperParsed responsePlantModelWrapperParsed = ResponsePlantModelWrapperParsed(
      resCode: responsePlantModelWrapperToParse.resCode,
      resDescr: parsedPlants,
    );

    return responsePlantModelWrapperParsed;
  }

  // Device type constants (from official Tecnosistemi app)
  // PICO devices use GetPICOState endpoint, others use GetHome endpoint
  static const int deviceTypePico = 1;

  // This method retrieves a specific plant and parses it into a structured format
  // lvdvType determines which API endpoint to use:
  //   - PICO devices (lvdvType == 1) use /api/v1/GetPICOState with picoSerial
  //   - Other devices (Polaris, ProAir, etc.) use /api/v1/GetHome with cuSerial
  static Future<DeviceStatus> retrieveSpecificPlantParsed(Ref ref, String serial, String pin, {int? lvdvType}) async {

    // Retrieve the new token from the AES crypt provider
    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    // Retrieve the current user's email from the global user email provider
    final String? currentEmail = ref.read(globalUserEmailProvider);

    // Retrieve the API key using the current email
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);

    // Log device type for debugging
    debugPrint('[PlantsResponsesParser] retrieveSpecificPlantParsed - serial: $serial, lvdvType: $lvdvType');

    if (lvdvType != null && lvdvType != deviceTypePico) {
      // Non-PICO devices (Polaris, ProAir, etc.) use GetHome with cuSerial
      debugPrint('[PlantsResponsesParser] Using GetHome endpoint (cuSerial) for device type: $lvdvType');
      return await _retrieveCuDeviceStatus(ref, newToken, authorization, serial, pin);
    } else {
      // PICO devices or unknown type (backward compatible) use GetPICOState
      debugPrint('[PlantsResponsesParser] Using GetPICOState endpoint (picoSerial) for device type: $lvdvType');
      final DeviceStatusResponse deviceStatusResponse = await ref
          .read(picoRestClientProvider)
          .getPicoState(newToken, authorization, serial, pin);
      return deviceStatusResponse.parsedResDescr;
    }
  }

  /// Retrieves the device status for CU devices (Polaris, ProAir, etc.)
  /// using the /api/v1/GetHome endpoint.
  /// The response format is a JSON array, not the standard ResCode/ResDescr wrapper.
  /// We map the CU-specific fields to the existing DeviceStatus model for UI compatibility.
  static Future<DeviceStatus> _retrieveCuDeviceStatus(
    Ref ref,
    String token,
    String authorization,
    String serial,
    String pin,
  ) async {
    final Dio dio = ref.read(networkHandlerProvider).dio;

    final Response<dynamic> response = await dio.get(
      '/api/v1/GetHome',
      queryParameters: {
        'cuSerial': serial,
        'PIN': pin,
      },
      options: Options(
        headers: {
          ...HeadersConstants.commonHeaders,
          'Token': token,
          'Authorization': authorization,
        },
      ),
    );

    // GetHome returns a JSON array: [{...}]
    final List<dynamic> responseData = response.data is List
        ? response.data as List<dynamic>
        : jsonDecode(response.data as String) as List<dynamic>;

    if (responseData.isEmpty) {
      throw Exception('GetHome returned empty array for serial: $serial');
    }

    final Map<String, dynamic> cuData = responseData[0] as Map<String, dynamic>;
    debugPrint('[PlantsResponsesParser] GetHome raw response: $cuData');

    // Map CU/Polaris fields to DeviceStatus for UI compatibility
    return _mapCuDataToDeviceStatus(cuData);
  }

  /// Retrieves zone data for CU/Polaris devices using GetCUState endpoint.
  ///
  /// The official app uses TWO separate API calls:
  ///   1. /api/v1/GetHome → basic device info (Serial, Name, IsOFF, etc.) — NO zones
  ///   2. /api/v1/GetCUState → full device state WITH "Zones" array
  ///
  /// GetCUState returns a JSON object (possibly wrapped in ResCode/ResDescr)
  /// containing a "Zones" field with an array of zone objects.
  /// Each zone has Gson-style fields: ZoneId, Name, Temp, SetTemp, isOff, etc.
  /// Temperatures are integers (e.g. "195" = 19.5°C) — divided by 10 in ZonaModel.
  static Future<({List<ZonaModel> zones, dynamic rawResponse})> retrieveZones(
    Ref ref,
    String serial,
    String pin,
  ) async {
    final Dio dio = ref.read(networkHandlerProvider).dio;
    final String? currentEmail = ref.read(globalUserEmailProvider);
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);
    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    debugPrint('[ZONES] Fetching zones from GetCUState for serial: $serial');

    try {
      final Response<dynamic> response = await dio.get(
        '/api/v1/GetCUState',
        queryParameters: {'cuSerial': serial, 'PIN': pin},
        options: Options(
          headers: {
            ...HeadersConstants.commonHeaders,
            'Token': newToken,
            'Authorization': authorization,
          },
        ),
      );

      debugPrint('[ZONES] GetCUState raw response type: ${response.data?.runtimeType}');

      // GetCUState may return:
      // 1. A JSON object with "Zones" directly: {"Serial": ..., "Zones": [...], ...}
      // 2. A ResCode/ResDescr wrapper: {"ResCode": 0, "ResDescr": "{...}"}
      // 3. A JSON array like GetHome: [{...}]
      dynamic parsedData = response.data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }

      Map<String, dynamic>? cuData;

      if (parsedData is Map<String, dynamic>) {
        // Check if it's a ResCode/ResDescr wrapper
        if (parsedData.containsKey('ResCode') && parsedData.containsKey('ResDescr')) {
          debugPrint('[ZONES] GetCUState returned ResCode wrapper, ResCode: ${parsedData['ResCode']}');
          final dynamic resDescr = parsedData['ResDescr'];
          if (resDescr is String) {
            final decoded = jsonDecode(resDescr);
            if (decoded is Map<String, dynamic>) {
              cuData = decoded;
            } else if (decoded is List && decoded.isNotEmpty) {
              cuData = decoded[0] as Map<String, dynamic>;
            }
          } else if (resDescr is Map<String, dynamic>) {
            cuData = resDescr;
          }
        } else {
          // Direct JSON object
          cuData = parsedData;
        }
      } else if (parsedData is List && parsedData.isNotEmpty) {
        cuData = parsedData[0] as Map<String, dynamic>;
      }

      if (cuData == null) {
        debugPrint('[ZONES] Could not parse GetCUState response');
        return (zones: <ZonaModel>[], rawResponse: parsedData);
      }

      debugPrint('[ZONES] GetCUState keys: ${cuData.keys.toList()}');

      // Extract the "Zones" array
      final dynamic zonesData = cuData['Zones'];
      debugPrint('[ZONES] Zones field type: ${zonesData?.runtimeType}, is null: ${zonesData == null}');

      if (zonesData == null) {
        debugPrint('[ZONES] No "Zones" field in GetCUState response');
        debugPrint('[ZONES] Full response for debugging: $cuData');
        return (zones: <ZonaModel>[], rawResponse: cuData);
      }

      if (zonesData is List) {
        final List<ZonaModel> zones = [];
        for (final zoneJson in zonesData) {
          if (zoneJson is Map<String, dynamic>) {
            final zone = ZonaModel.fromJson(zoneJson);
            debugPrint('[ZONES] Parsed zone: ${zone.name} - temp: ${zone.currentTemp}°C, '
                'setTemp: ${zone.setTemp}°C, isOff: ${zone.isOff}');
            zones.add(zone);
          }
        }
        debugPrint('[ZONES] Found ${zones.length} zones');
        return (zones: zones, rawResponse: cuData);
      }

      debugPrint('[ZONES] Unexpected Zones type: ${zonesData.runtimeType}');
      return (zones: <ZonaModel>[], rawResponse: cuData);
    } catch (e) {
      debugPrint('[ZONES] Error fetching zones from GetCUState: $e');
      return (zones: <ZonaModel>[], rawResponse: 'ERROR: $e');
    }
  }

  /// Maps the GetHome response fields to a DeviceStatus object.
  /// GetHome fields:
  ///   Serial, Name, FWVer, IsOFF, IsCooling, OperatingModeCooling,
  ///   LastConfigUpdate, LastSyncUpdate, NumErrors, Icon, IrPresent,
  ///   TempCan, IP, FInv (internal fan), FEst (external fan)
  static DeviceStatus _mapCuDataToDeviceStatus(Map<String, dynamic> cuData) {
    final bool isOff = cuData['IsOFF'] == true;
    final String name = cuData['Name'] ?? 'Unknown';
    final String fwVer = cuData['FWVer'] ?? '';
    final String ip = cuData['IP'] ?? '';
    final String serial = cuData['Serial'] ?? '';
    final int fInv = cuData['FInv'] ?? 0;
    final int fEst = cuData['FEst'] ?? 0;
    final bool isCooling = cuData['IsCooling'] == true;
    final int operatingModeCooling = cuData['OperatingModeCooling'] ?? 0;
    final int irPresent = cuData['IrPresent'] ?? 0;
    final String tempCan = cuData['TempCan'] ?? '0';

    // Map to DeviceStatus fields:
    // on_off: 0 = off, 1 = on (inverted from IsOFF)
    // mod: operating mode - map from CU fields
    // speed/spd_rich: use FInv (internal fan speed) as primary fan speed indicator
    // spd_row: use FEst (external fan speed)
    return DeviceStatus(
      cmd: 'GetHome',
      frm: serial,
      ip: ip,
      fwVer: fwVer,
      vr: 0,
      reset: null,
      wRssi: 0,
      onOff: isOff ? 0 : 1,
      mod: isCooling ? operatingModeCooling : 0,
      speed: fInv,
      spdRow: fEst,
      spdRich: fInv,
      nightMod: 0,
      sUmd: 0,
      idSlave: 0,
      name: name,
      ledOnOff: 0,
      ledOnOffBreve: 0,
      ledColor: 0,
      hasSlave: 0,
      res: 0,
      lastpk: jsonEncode({
        'idp': 0,
        'frm': serial,
        'cmd': 'GetHome',
        'ip': ip,
        'fw_ver': fwVer,
        'fw_note': '',
        'vr': 0,
        'modello': 0,
        'BaseTop': 0,
        'Grd_DM': '',
        'config_mod': 0,
        'id_slave': 0,
        'name': name,
        'mod': isCooling ? operatingModeCooling : 0,
        'step_mod': 0,
        'on_off': isOff ? 0 : 1,
        'speed': fInv,
        'spd_rich': fInv,
        'spd_row': fEst,
        'fan_dir': 0,
        'verso': 0,
        's_umd': 0,
        's_co2': 0,
        'umd_raw': 0,
        'AMB_tmpr': double.tryParse(tempCan) != null ? double.parse(tempCan) / 10.0 : 0.0,
        'Delta_tmprCiclo': 0,
        'Delta_umdCiclo': 0,
        'v_tmpr': 0.0,
        'v_umd': 0.0,
        'v_AirQ': 0,
        'v_Tvoc': 0,
        'v_ECo2': 0,
        'par_rt': <int>[],
        'par_mm': <int>[],
        'par_amb': <int>[],
        'par_ext': <int>[],
        'night_mod': 0,
        'led_on_off': 0,
        'led_on_off_breve': 0,
        'led_color': 0,
        'm_crono': 0,
        'tw_active': 0,
        'err': <List<dynamic>>[],
        'man': <int>[],
        'has_slave': 0,
        'bmp_slave': 0,
        'cntr': 0,
        'memfree': 0,
        'up_time': 0,
        'date': '',
        'time': '',
        'week': 0,
        'res': 0,
      }),
      timezone: null,
      err: const [],
      man: const [],
      parExt: const [],
      parAmb: const [],
      mCrono: 0,
      twActive: 0,
    );
  }

}
