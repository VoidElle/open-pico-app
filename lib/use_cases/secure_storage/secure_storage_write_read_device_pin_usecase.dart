import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/constants/secure_storage_constants.dart';

class SecureStorageWriteReadDevicePinUsecase {

  FlutterSecureStorage flutterSecureStorage;

  SecureStorageWriteReadDevicePinUsecase(this.flutterSecureStorage);

  // Method to read login data from secure storage
  Future<Map<String, dynamic>> readData(String serial) async {

    final String key = SecureStorageConstants.devicePinKey(serial);
    final String? pin = await flutterSecureStorage.read(key: key);

    // If either email or password is null, return an empty map
    if (pin == null) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{
      'pin': pin,
    };
  }

  // Method to write login data to secure storage
  Future<void> writeData(String serial, String pin) async {
    final String key = SecureStorageConstants.devicePinKey(serial);
    await flutterSecureStorage.write(key: key, value: pin);
  }

  // Method to delete login data from secure storage
  Future<void> deleteData(String serial) async {
    final String key = SecureStorageConstants.devicePinKey(serial);
    await flutterSecureStorage.delete(key: key);
  }

}