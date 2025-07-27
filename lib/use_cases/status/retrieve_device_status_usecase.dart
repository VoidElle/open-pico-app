import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/responses/device_status.dart';
import '../../utils/parsers/plants_responses_parser.dart';
import '../network/core/network_handler.dart';

part 'generated/retrieve_device_status_usecase.g.dart';

class RetrieveDeviceStatusUsecase {

  final Ref ref;
  final Dio dio;

  RetrieveDeviceStatusUsecase(this.ref, this.dio);

  Future<DeviceStatus> execute({
    required String deviceSerial,
    required String devicePin,
  }) async {
    return await PlantsResponsesParser
        .retrieveSpecificPlantParsed(ref, deviceSerial, devicePin);
  }

}

// Exposing the use case with a provider
@Riverpod()
RetrieveDeviceStatusUsecase getRetrieveDeviceStatusUsecase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return RetrieveDeviceStatusUsecase(ref, networkHandler.dio);
}