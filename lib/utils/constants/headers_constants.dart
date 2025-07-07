import 'network_constants.dart';

class HeadersConstants {

  // Headers used in common requests without a content type
  static const Map<String, dynamic> commonHeaders = {
    'Accept-Encoding': 'gzip',
    'Connection': 'Keep-Alive',
    'Host': NetworkConstants.host,
    'User-Agent': NetworkConstants.userAgent,
    'UserObj-Agent': NetworkConstants.userObjAgent,
  };

  // Headers used in common requests with JSON content type
  static const Map<String, dynamic> commonWithJsonRequestHeaders = {
    ...commonHeaders,
    'Content-Type': 'application/json',
  };

}