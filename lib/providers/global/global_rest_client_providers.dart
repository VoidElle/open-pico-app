import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/use_cases/network/core/network_handler.dart';
import 'package:open_pico_app/use_cases/network/rest_clients/login_rest_client.dart';
import 'package:open_pico_app/use_cases/network/rest_clients/pico_rest_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/global_rest_client_providers.g.dart';

/// This class is responsible to expose the providers for the rest clients

/// A provider for the AESCrypt instance, which is used for AES encryption and decryption
@Riverpod(keepAlive: true)
LoginRestClient loginRestClient(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LoginRestClient(networkHandler.dio);
}

/// A provider for the PicoRestClient instance, which is used for making requests to the Pico API
@Riverpod(keepAlive: true)
PicoRestClient picoRestClient(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return PicoRestClient(networkHandler.dio);
}