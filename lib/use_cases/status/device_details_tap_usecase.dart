import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/models/responses/common_response_wrapper.dart';
import 'package:open_pico_app/pages/pico_status_page.dart';
import 'package:open_pico_app/use_cases/secure_storage/secure_storage_write_read_device_pin_usecase.dart';
import 'package:open_pico_app/widgets/dialogs/text_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/responses/device_status.dart';
import '../../repositories/secure_storage_repository.dart';
import '../../utils/parsers/plants_responses_parser.dart';
import '../../widgets/dialogs/input_pin_dialog.dart';
import '../network/core/network_handler.dart';

part 'generated/device_details_tap_usecase.g.dart';

class DeviceDetailsTapUsecase {

  final Ref ref;
  final Dio dio;

  DeviceDetailsTapUsecase(this.ref, this.dio);

  Future<void> execute({
    required BuildContext context,
    required String serial,
  }) async {

    // Retrieve the PIN from the Secure Storage
    final SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase = SecureStorageWriteReadDevicePinUsecase(SecureStorageRepository.instance);
    final Map<String, dynamic> data = await secureStorageWriteReadDevicePinUsecase.readData(serial);
    if (data.isEmpty || !data.containsKey("pin")) {
      await handleInputPin(context, serial, secureStorageWriteReadDevicePinUsecase, false);
      return;
    }

    // Get the PIN from the retrieved data
    final String pin = data['pin'];

    try {

      // Retrieve the specific PICO device status
      final DeviceStatus deviceStatus = await PlantsResponsesParser
          .retrieveSpecificPlantParsed(ref, serial, pin);

      // Redirect the user to the PicoStatusPage with the device's info
      context.go(PicoStatusPage.route, extra: deviceStatus);

      return;
    } catch (e) {

      // Check if the error is an invalid PIN error
      if (e is DioException && e.response != null) {
        if (e.response?.statusCode == 400) {
          final Map<String, dynamic> data = e.response?.data;
          if (data.isNotEmpty) {
            final CommonResponseWrapper response = CommonResponseWrapper.fromJson(data);
            if (response.resCode == 2) {
              await handleInputPin(context, serial, secureStorageWriteReadDevicePinUsecase, true);
              return;
            }
          }
        }
      }

      // If it is not an invalid PIN error, shows a generic error dialog
      TextDialog.show(
        context: context,
        message: "An error has occurred\n(${e.toString()})",
        title: "Error",
      );

    }

  }

  Future<void> handleInputPin(BuildContext context, String serial, SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase, bool previousPinError) async {
    final String? pin = await InputPinDialog.show(context, previousPinError);
    if (pin != null) {
      await secureStorageWriteReadDevicePinUsecase.writeData(serial, pin);
      await execute(context: context, serial: serial);
    }
  }

}

// Exposing the use case with a provider
@Riverpod()
DeviceDetailsTapUsecase getDeviceDetailsTapUsecase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return DeviceDetailsTapUsecase(ref, networkHandler.dio);
}