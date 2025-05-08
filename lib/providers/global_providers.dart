import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:open_pico_app/utils/aes_crypt.dart';
import 'package:open_pico_app/utils/constants.dart';

part 'global_providers.g.dart';

/// A provider for the AESCrypt instance, which is used for AES encryption and decryption.
@riverpod
AESCrypt aesCryptProvider(Ref ref) => AESCrypt(Constants.deviceId);