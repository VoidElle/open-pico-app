import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/secure_storage_repository.dart';
import '../network/core/network_handler.dart';
import '../secure_storage/secure_storage_write_read_device_pin_usecase.dart';

part 'generated/get_device_pin_usecase.g.dart';

class GetDevicePinUsecase {

  final Ref ref;
  final Dio dio;

  GetDevicePinUsecase(this.ref, this.dio);

  Future<String> execute({
    required String deviceSerial,
  }) async {

    // Retrieve the PIN from the Secure Storage
    final SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase = SecureStorageWriteReadDevicePinUsecase(SecureStorageRepository.instance);
    final Map<String, dynamic> data = await secureStorageWriteReadDevicePinUsecase.readData(deviceSerial);

    // Get the PIN from the retrieved data
    return data['pin'];
  }

}

// Exposing the use case with a provider
@Riverpod()
GetDevicePinUsecase getGetDevicePinUsecase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return GetDevicePinUsecase(ref, networkHandler.dio);
}