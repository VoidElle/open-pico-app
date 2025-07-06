class SecureStorageConstants {

  // Keys for login credentials
  static const String loginEmailKey = 'LOGIN_EMAIL';
  static const String loginPasswordKey = 'LOGIN_PASSWORD';

  // Keys for retrieving a PIN of a device
  static String devicePinKey(String serial) {
    return 'DEVICE_PIN_$serial';
  }

}