import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/use_cases/network/core/network_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/constants/network_constants.dart';

part 'generated/get_plants_use_case.g.dart';

// Headers used in the request use case
const Map<String, dynamic> commonHeaders = {
  'Accept-Encoding': 'gzip',
  'Connection': 'Keep-Alive',
  'Host': NetworkConstants.host,
  'User-Agent': NetworkConstants.userAgent,
  'UserObj-Agent': NetworkConstants.userObjAgent,
};

// This use case is responsible for making a login
// request to the server and returning the response.
class GetPlantsUseCase {

  final Ref ref;
  final Dio dio;

  GetPlantsUseCase(this.ref, this.dio);

  Future<void> execute({
    required BuildContext context,
  }) async {

  }

}

// Exposing the use case with a provider
@Riverpod()
GetPlantsUseCase getPlantsUseCase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return GetPlantsUseCase(ref, networkHandler.dio);
}