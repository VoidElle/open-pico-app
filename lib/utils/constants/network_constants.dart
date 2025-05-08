class NetworkConstants {

  // The base API url
  static const String baseUrl = 'https://$host/apiTS/v2/';

  // The host name of the API
  static const String host = 'proair.azurewebsites.net';

  // The API key used for all the requests
  static const String apiKey = "Basic VXNyUHJvQWlyOlB3ZFByb0Fpcg==";

  // Token used for the requests headers
  // (It is just to simulate a real device)
  static const String token = 'Ga5mM61KCm5Bk18lhD5J999jC2Mu0Vaf';

  // The platform used for push notifications
  static const String pushNotificationsPlatform = "fcm2";

  // The token used for push notifications
  // (It is just to simulate a real device)
  static const String pushNotificationsToken = "d5-l8Ok9SequOYXXGVy3X_:APA91bG67RFYtPjfDSlgpzEZqt8mxu78eGkSrnOL3XUn6T1tErpawd5yAfHGID1Z0HcrP7OO0dFtygndvPPy-1G5BdJKdnFB79IQGvczu-qxMcwuWq89Pp8";

  // The user agent used for the requests
  // (It is just to simulate a real device)
  static const String userAgent = "Dalvik/2.1.0 (Linux; U; Android 16; sdk_gphone64_arm64 Build/BP22.250325.006)";

  // Backend results codes
  static const int result_error = -1;
  static const int result_ok = 0;
  static const int result_incorrectPwdUser = 1;
  static const int result_userToActivate = 2;
  static const int result_userBlocked = 3;
  static const int result_userNotFound = 4;
  static const int result_deviceNotValid = 5;
  static const int result_expiredPwd = 6;
  static const int result_expiredTemporaryPwd = 7;
  static const int result_moreDevices = 8;
  static const int result_mailExists = 9;
  static const int result_newTermOfUse = 10;
  static const int result_wifi = 1234;

}