import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/models/requests/request_login_model.dart';
import 'package:open_pico_app/network/network_handler.dart';
import 'package:open_pico_app/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_usecase.g.dart';

// This use case is responsible for making a login
// request to the server and returning the response.
class LoginUseCase {

  final Dio dio;

  LoginUseCase(this.dio);

  void request({
    required String username,
    required String clearPassword,
  }) {

    final RequestLoginModel requestLoginModel = RequestLoginModel(
      deviceId: Constants.deviceId,
      platform: Constants.pushNotificationsPlatform,
      password: '',
      tokenPush: Constants.pushNotificationsToken,
      username: username,
    );

  }

}

// Exposing the use case with a provider
@Riverpod()
LoginUseCase loginUseCase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LoginUseCase(networkHandler.dio);
}