import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/responses/common_response_wrapper.dart';
import '../../models/responses/device_status.dart';
import '../../models/responses/response_device_model.dart';
import '../../repositories/secure_storage_repository.dart';
import '../network/core/network_handler.dart';
import '../pico/pico_execute_command_usecase.dart';
import '../secure_storage/secure_storage_write_read_device_pin_usecase.dart';

part 'generated/execute_change_status_command_usecase.g.dart';

class ExecuteChangeStatusCommandUsecase {

  final Ref ref;
  final Dio dio;

  ExecuteChangeStatusCommandUsecase(this.ref, this.dio);

  Future<CommonResponseWrapper> execute({
    required DeviceStatus deviceStatus,
    required ResponseDeviceModel responseDeviceModel,
    required String command,
  }) async {

    // Retrieve the PIN from the Secure Storage
    final SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase = SecureStorageWriteReadDevicePinUsecase(SecureStorageRepository.instance);
    final Map<String, dynamic> data = await secureStorageWriteReadDevicePinUsecase.readData(responseDeviceModel.serial);

    // Get the PIN from the retrieved data
    final String devicePin = data['pin'];

    return await ref
        .read(getPicoExecuteCommandUsecaseProvider)
        .execute(
          command: command,
          deviceName: deviceStatus.name,
          devicePin: devicePin,
          deviceSerial: responseDeviceModel.serial,
        );
  }

}

// Exposing the use case with a provider
@Riverpod()
ExecuteChangeStatusCommandUsecase getExecuteChangeStatusCommandUsecase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return ExecuteChangeStatusCommandUsecase(ref, networkHandler.dio);
}