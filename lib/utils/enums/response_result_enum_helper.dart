import 'package:open_pico_app/utils/constants/network_constants.dart';

// enum describing the possible response results from the server
enum ResponseResultEnum {
  error,
  ok,
  incorrectPwdUser,
  userToActivate,
  userBlocked,
  userNotFound,
  deviceNotValid,
  expiredPwd,
  expiredTemporaryPwd,
  moreDevices,
  mailExists,
  newTermOfUse,
  wifi,
}

class ResponseResultEnumHelper {

  // Mapping of enum values to their corresponding codes
  static const Map<int, ResponseResultEnum> _enumToCodeMap = {
    NetworkConstants.result_error: ResponseResultEnum.error,
    NetworkConstants.result_ok: ResponseResultEnum.ok,
    NetworkConstants.result_incorrectPwdUser: ResponseResultEnum.incorrectPwdUser,
    NetworkConstants.result_userToActivate: ResponseResultEnum.userToActivate,
    NetworkConstants.result_userBlocked: ResponseResultEnum.userBlocked,
    NetworkConstants.result_userNotFound: ResponseResultEnum.userNotFound,
    NetworkConstants.result_deviceNotValid: ResponseResultEnum.deviceNotValid,
    NetworkConstants.result_expiredPwd: ResponseResultEnum.expiredPwd,
    NetworkConstants.result_expiredTemporaryPwd: ResponseResultEnum.expiredTemporaryPwd,
    NetworkConstants.result_moreDevices: ResponseResultEnum.moreDevices,
    NetworkConstants.result_mailExists: ResponseResultEnum.mailExists,
    NetworkConstants.result_newTermOfUse: ResponseResultEnum.newTermOfUse,
    NetworkConstants.result_wifi: ResponseResultEnum.wifi,
  };

  // Function to convert the received code to the corresponding enum value
  static ResponseResultEnum fromCode(int code) {
    if (_enumToCodeMap.containsKey(code)) {
      return _enumToCodeMap[code]!;
    } else {
      throw Exception('Invalid code: $code');
    }
  }

  // Function to convert the enum value to its corresponding code
  static int toCode(ResponseResultEnum enumValue) {
    return _enumToCodeMap.entries
        .firstWhere((entry) => entry.value == enumValue)
        .key;
  }

}