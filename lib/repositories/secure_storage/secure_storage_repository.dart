import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageRepository {

  static FlutterSecureStorage? _instance;

  SecureStorageRepository() {
    if (_instance != null) {
      throw Exception('SecureStorageRepository is a singleton and has already been instantiated.');
    } else {
      final AndroidOptions androidOptions = AndroidOptions(
        encryptedSharedPreferences: true,
      );
      _instance = FlutterSecureStorage(
        aOptions: androidOptions,
      );
    }
  }

  static FlutterSecureStorage get instance {
    if (_instance == null) {
      throw Exception('SecureStorageRepository has not been initialized.');
    }
    return _instance!;
  }

}