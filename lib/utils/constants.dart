class Constants {

  // The base API url
  static const String baseUrl = 'https://proair.azurewebsites.net/apiTS/v2/';

  // The initialization vector used for the AES encryption
  static const String cypherPadding = "PKCS7";

  // The salt used for the AES encryption
  static const String cypherSalt = "ns91wr48";

  // The device ID used for the AES encryption
  static const String deviceId = "c610101212ff9aec";

  // The platform used for push notifications
  static const String pushNotificationsPlatform = "fcm2";

  // The token used for push notifications
  // (It is just to simulate a real device)
  static const String pushNotificationsToken = "d5-l8Ok9SequOYXXGVy3X_:APA91bG67RFYtPjfDSlgpzEZqt8mxu78eGkSrnOL3XUn6T1tErpawd5yAfHGID1Z0HcrP7OO0dFtygndvPPy-1G5BdJKdnFB79IQGvczu-qxMcwuWq89Pp8";

}