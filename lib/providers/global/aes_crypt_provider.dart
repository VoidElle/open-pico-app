import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/utils/aes_crypt.dart';
import 'package:open_pico_app/utils/constants/cypher_constants.dart';

final aesCryptProvider = Provider<AESCrypt>((ref) {
  return AESCrypt(ref, CypherConstants.deviceId);
});