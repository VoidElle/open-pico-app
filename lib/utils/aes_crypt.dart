import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/utils/constants/cypher_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'aes_crypt.g.dart';

class AESCrypt {

  late final Key key;
  final IV iv = IV(Uint8List(16));

  /// Constructor for AESCrypt
  AESCrypt(String deviceId) {

    // The key string is the first 8 characters of the device ID + the cypher salt
    final String keyStr = deviceId.substring(0, 8) + CypherConstants.cypherSalt;

    final Uint8List bytes = utf8.encode(keyStr);
    final List<int> digest = sha256.convert(bytes).bytes;
    key = Key(Uint8List.fromList(digest));
  }

  // Encrypts the given plain text using AES encryption
  String encryptText(String plainText) {
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: CypherConstants.cypherPadding));
    final Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Decrypts the given base64 text using AES decryption
  String decryptText(String base64Text) {
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: CypherConstants.cypherPadding));
    return encrypter.decrypt64(base64Text, iv: iv);
  }

}

// Expose the AESCrypt instance as a provider
@Riverpod(keepAlive: true)
AESCrypt aesCrypt(Ref ref) => AESCrypt(CypherConstants.deviceId);