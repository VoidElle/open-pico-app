import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:open_pico_app/utils/constants.dart';

class AESCrypt {

  late final Key key;
  final IV iv = IV(Uint8List(16));

  /// Constructor for AESCrypt
  AESCrypt(String deviceId) {

    // The key string is the first 8 characters of the device ID + the cypher salt
    final String keyStr = deviceId.substring(0, 8) + Constants.cypherSalt;

    final Uint8List bytes = utf8.encode(keyStr);
    final List<int> digest = sha256.convert(bytes).bytes;
    key = Key(Uint8List.fromList(digest));
  }

  // Encrypts the given plain text using AES encryption
  String encryptText(String plainText) {
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: Constants.cypherPadding));
    final Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Decrypts the given base64 text using AES decryption
  String decryptText(String base64Text) {
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: Constants.cypherPadding));
    return encrypter.decrypt64(base64Text, iv: iv);
  }

}