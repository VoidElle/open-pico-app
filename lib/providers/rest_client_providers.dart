import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/network/network_handler.dart';
import 'package:open_pico_app/network/rest/login_rest_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rest_client_providers.g.dart';

/// This class is responsible to expose the providers for the rest clients

/// A provider for the AESCrypt instance, which is used for AES encryption and decryption
@Riverpod(keepAlive: true)
LoginRestClient loginRestClient(Ref ref) {
  final NetworkHandler networkHandler = ref.watch(networkHandlerProvider);
  return LoginRestClient(networkHandler.dio);
}