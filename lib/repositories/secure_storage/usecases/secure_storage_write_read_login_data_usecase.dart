import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../utils/constants/secure_storage_constants.dart';

class SecureStorageWriteReadLoginDataUseCase {

  FlutterSecureStorage flutterSecureStorage;

  SecureStorageWriteReadLoginDataUseCase(this.flutterSecureStorage);

  // Method to read login data from secure storage
  Future<Map<String, dynamic>> readData() async {

    final String? email = await flutterSecureStorage.read(key: SecureStorageConstants.loginEmailKey);
    final String? password = await flutterSecureStorage.read(key: SecureStorageConstants.loginPasswordKey);

    // If either email or password is null, return an empty map
    if (email == null || password == null) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  // Method to write login data to secure storage
  Future<void> writeData(String email, String password) async {
    await flutterSecureStorage.write(key: SecureStorageConstants.loginEmailKey, value: email);
    await flutterSecureStorage.write(key: SecureStorageConstants.loginPasswordKey, value: password);
  }

  // Method to delete login data from secure storage
  Future<void> deleteData() async {
    await flutterSecureStorage.delete(key: SecureStorageConstants.loginEmailKey);
    await flutterSecureStorage.delete(key: SecureStorageConstants.loginPasswordKey);
  }

}