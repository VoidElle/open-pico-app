import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/requests/request_command_model.dart';
import '../../models/responses/common_response_wrapper.dart';
import '../../providers/global/global_providers.dart';
import '../../providers/global/global_rest_client_providers.dart';
import '../../repositories/secure_storage_repository.dart';
import '../../utils/aes_crypt.dart';
import '../../utils/constants/network_constants.dart';
import '../network/core/network_handler.dart';
import '../secure_storage/secure_storage_write_read_device_pin_usecase.dart';

part 'generated/pico_execute_command_usecase.g.dart';

class PicoExecuteCommandUsecase {

  final Ref ref;
  final Dio dio;

  PicoExecuteCommandUsecase(this.ref, this.dio);

  Future<CommonResponseWrapper> execute({
    required String deviceName,
    required String deviceSerial,
    required String command,
  }) async {

    // Retrieve the PIN from the Secure Storage
    final SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase = SecureStorageWriteReadDevicePinUsecase(SecureStorageRepository.instance);
    final Map<String, dynamic> data = await secureStorageWriteReadDevicePinUsecase.readData(deviceSerial);

    // Get the PIN from the retrieved data
    final String devicePin = data['pin'];

    // Create the request model to send
    final RequestCommandModel requestCommandModel = RequestCommandModel(
      command: command,
      deviceName: deviceName,
      devicePin: devicePin,
      deviceSerial: deviceSerial,
    );

    // Retrieve the new token from the AES crypt provider
    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    // Retrieve the current user's email from the global user email provider
    final String? currentEmail = ref.read(globalUserEmailProvider);

    // Retrieve the API key using the current email
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);

    final CommonResponseWrapper deviceStatusResponse = await ref
        .read(picoRestClientProvider)
        .executeCommand(newToken, authorization, deviceSerial, devicePin, requestCommandModel);

    // Increment the IDP counter after the request
    ref.read(globalIdpCounterRepositoryProvider.notifier).increment();

    return deviceStatusResponse;
  }

}

// Exposing the use case with a provider
@Riverpod()
PicoExecuteCommandUsecase getPicoExecuteCommandUsecase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return PicoExecuteCommandUsecase(ref, networkHandler.dio);
}