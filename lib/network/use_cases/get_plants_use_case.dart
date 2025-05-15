import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/network/network_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/constants/network_constants.dart';

part 'get_plants_use_case.g.dart';

// Headers used in the request use case
const Map<String, dynamic> getPlantsUseCaseHeaders = {
  'Accept-Encoding': 'gzip',
  // 'Authorization': NetworkConstants.loggedApiKey,
  'Connection': 'Keep-Alive',
  'Host': NetworkConstants.host,
  // Todo: Dynamic 'Token': NetworkConstants.token,
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