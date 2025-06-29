import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/pages/auth_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../network/network_handler.dart';
import '../../repositories/secure_storage/secure_storage_repository.dart';
import '../../repositories/secure_storage/usecases/secure_storage_write_read_login_data_usecase.dart';

part 'generated/logout_use_case.g.dart';

class LogoutUseCase {

  final Ref ref;
  final Dio dio;

  LogoutUseCase(this.ref, this.dio);

  Future<void> execute({
    required BuildContext context,
  }) async {

    // Remove the user data from Secure Storage
    final SecureStorageWriteReadLoginDataUseCase secureStorageWriteReadLoginDataUseCase = SecureStorageWriteReadLoginDataUseCase(SecureStorageRepository.instance);
    await secureStorageWriteReadLoginDataUseCase.deleteData();
    debugPrint("[i] User data deleted from Secure storage.");

    // Redirect the user to the AuthPage
    context.go(AuthPage.route);

  }

}

// Exposing the use case with a provider
@Riverpod()
LogoutUseCase getLogoutUseCase(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LogoutUseCase(ref, networkHandler.dio);
}