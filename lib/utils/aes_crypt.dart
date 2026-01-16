import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/repositories/global_token_repository.dart';
import 'package:open_pico_app/utils/constants/cypher_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/aes_crypt.g.dart';

class AESCrypt {

  late final Ref ref;
  late final Key key;
  final IV iv = IV(Uint8List(16));

  /// Constructor for AESCrypt
  AESCrypt(Ref ref, String deviceId) {

    this.ref = ref;

    // The key string is the first 8 characters of the device ID + the cypher salt
    final String keyStr = deviceId.substring(0, 8) + CypherConstants.cypherSalt;

    // Create SHA-256 hash and take only first 32 bytes, matching Java implementation
    final Uint8List bytes = utf8.encode(keyStr);
    final List<int> digest = sha256.convert(bytes).bytes;
    final Uint8List keyBytes = Uint8List(32);
    for (int i = 0; i < 32 && i < digest.length; i++) {
      keyBytes[i] = digest[i];
    }

    key = Key(keyBytes);
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

  // This function retrieves a new token by incrementing the last part of the decrypted token
  // !!! WARNING: Every time an API call is done, a new token needs to be generated with this function !!!
  String? retrieveNewToken() {
    try {
      final String oldToken = GlobalTokenRepository.token ?? '';
      final String decryptedToken;

      try {
        decryptedToken = decryptText(oldToken);
      } catch (e) {
        print('Error decrypting token: $e');
        return null;
      }

      final List<String> splitToken = decryptedToken.split("_");
      if (splitToken.length == 2) {
        try {
          // Use int parsing like Java's Long.parseLong instead of double
          final int parsedInt = int.parse(splitToken[1]) + 1;

          final String newTokenPlain = "${splitToken[0]}_$parsedInt";
          final String newToken = encryptText(newTokenPlain)
              .replaceAll("\r", "")
              .replaceAll("\n", "");

          // For debugging - you can remove this later
          print('Old token: $oldToken');
          print('Decrypted: $decryptedToken');
          print('New token plain: $newTokenPlain');
          print('New token encrypted: $newToken');

          // Set the new token
          GlobalTokenRepository.token = newToken;

          return newToken;
        } catch (e) {
          print('Error parsing or encrypting: $e');
        }
      }
    } catch (e) {
      print('General error in retrieveNewToken: $e');
    }
    return null;
  }

}

// Expose the AESCrypt instance as a provider
@Riverpod(keepAlive: true)
AESCrypt aesCrypt(Ref ref) => AESCrypt(ref, CypherConstants.deviceId);