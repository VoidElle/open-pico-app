import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/models/requests/request_login_model.dart';
import 'package:open_pico_app/models/responses/response_user_model.dart';
import 'package:open_pico_app/repositories/global_token_repository.dart';
import 'package:open_pico_app/use_cases/network/core/network_handler.dart';
import 'package:open_pico_app/use_cases/network/rest_clients/login_rest_client.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/repositories/secure_storage_repository.dart';
import 'package:open_pico_app/use_cases/secure_storage/secure_storage_write_read_login_data_usecase.dart';
import 'package:open_pico_app/utils/constants/cypher_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/global/global_providers.dart';
import '../../../providers/global/global_rest_client_providers.dart';
import '../../../providers/pages/auth_page_providers.dart';
import '../../../utils/aes_crypt.dart';
import '../../../utils/constants/network_constants.dart';

part 'generated/login_use_case.g.dart';

// Headers used in the request use case
const Map<String, dynamic> loginUseCaseHeaders = {
  'Accept-Encoding': 'gzip',
  // 'Authorization': NetworkConstants.unloggedApiKey,
  'Connection': 'Keep-Alive',
  'Content-Length': 284,
  'Content-Type': 'application/json',
  'Host': NetworkConstants.host,
  'Token': NetworkConstants.startingToken,
  'User-Agent': NetworkConstants.userAgent,
};

// This use case is responsible for making a login
// request to the server and returning the response.
class LoginUseCase {

  final Ref ref;
  final Dio dio;

  LoginUseCase(this.ref, this.dio);

  Future<void> execute({
    required BuildContext context,
    bool savePassword = false,
  }) async {

    // If the form is not valid, return early
    if (!ref.watch(authPageFormKeyProvider).currentState!.validate()) {
      return;
    }

    // Retrieve the values from the text fields
    final String email = ref.watch(authPageEmailControllerProvider).text;
    final String clearPassword = ref.watch(authPagePasswordControllerProvider).text;

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

    // Set the global email
    ref.read(globalUserEmailProvider.notifier).set(email);

    // Execute the login request
    final LoginRestClient loginRestClient = ref.read(loginRestClientProvider);

    // Even if we have the email info, we need to retrieve the unlogged api key
    // so we do not include the email in the function
    final String authorization = NetworkConstants.retrieveApiKey(null);

    // Perform the login request
    final ResponseUserModel responseUserModel = await loginRestClient.login(authorization, requestLoginModel);

    // Retrieve the token from the response
    final String token = responseUserModel.token;

    // Set the user model in the global state
    GlobalTokenRepository.token = token;

    // If the savePassword flag is true, save the email and encrypted password to secure storage
    if (savePassword) {
      final SecureStorageWriteReadLoginDataUseCase secureStorageWriteReadLoginDataUseCase = SecureStorageWriteReadLoginDataUseCase(SecureStorageRepository.instance);
      await secureStorageWriteReadLoginDataUseCase.writeData(email, clearPassword);
      debugPrint("[i] Login data saved to secure storage.");
    }

    // Navigate to the home page
    context.go(PlantsListPage.route);
  }

}

// Exposing the use case with a provider
@Riverpod()
LoginUseCase loginUseCase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LoginUseCase(ref, networkHandler.dio);
}