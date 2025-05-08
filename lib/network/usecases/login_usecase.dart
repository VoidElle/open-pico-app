import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/models/requests/request_login_model.dart';
import 'package:open_pico_app/network/network_handler.dart';
import 'package:open_pico_app/network/rest/login_rest_client.dart';
import 'package:open_pico_app/utils/constants/cypher_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/rest_client_providers.dart';
import '../../utils/aes_crypt.dart';
import '../../utils/constants/network_constants.dart';

part 'login_usecase.g.dart';

// Headers used in the request use case
const Map<String, dynamic> loginUseCaseHeaders = {
  'Accept-Encoding': 'gzip',
  'Authorization': NetworkConstants.apiKey,
  'Connection': 'Keep-Alive',
  'Content-Length': 284,
  'Content-Type': 'application/json',
  'Host': NetworkConstants.host,
  'Token': NetworkConstants.token,
  'User-Agent': NetworkConstants.userAgent,
};

// This use case is responsible for making a login
// request to the server and returning the response.
class LoginUseCase {

  final Ref ref;
  final Dio dio;

  LoginUseCase(this.ref, this.dio);

  void executeRequest({
    required String email,
    required String clearPassword,
  }) {

    // Encrypt the password using AES encryption
    final String encryptedPassword = ref.read(aesCryptProvider).encryptText(clearPassword);

    // Create the request model
    final RequestLoginModel requestLoginModel = RequestLoginModel(
      deviceId: CypherConstants.deviceId,
      platform: NetworkConstants.pushNotificationsPlatform,
      password: encryptedPassword,
      tokenPush: NetworkConstants.pushNotificationsToken,
      username: email,
    );

    // Execute the login request
    final LoginRestClient loginRestClient = ref.read(loginRestClientProvider);
    final dynamic response = loginRestClient.login(requestLoginModel);

  }

}

// Exposing the use case with a provider
@Riverpod()
LoginUseCase loginUseCase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LoginUseCase(ref, networkHandler.dio);
}