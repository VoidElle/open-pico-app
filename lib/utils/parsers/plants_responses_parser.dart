import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/models/responses/response_plant_model_wrapper_parsed.dart';

import '../../models/responses/device_status_response.dart';
import '../../models/responses/response_plant_model.dart';
import '../../models/responses/common_response_wrapper.dart';
import '../../providers/global/global_providers.dart';
import '../../providers/global/global_rest_client_providers.dart';
import '../aes_crypt.dart';
import '../constants/network_constants.dart';

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

  // This method retrieves a specific plant and parses it into a structured format
  static Future<DeviceStatus> retrieveSpecificPlantParsed(Ref ref, String serial, String pin) async {

    // Retrieve the new token from the AES crypt provider
    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    // Retrieve the current user's email from the global user email provider
    final String? currentEmail = ref.read(globalUserEmailProvider);

    // Retrieve the API key using the current email
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);

    // Fetch the plants data from the REST client using the new token and authorization header
    final DeviceStatusResponse deviceStatusResponse = await ref
        .read(picoRestClientProvider)
        .getPicoState(newToken, authorization, serial, pin);

    return deviceStatusResponse.parsedResDescr;
  }

}