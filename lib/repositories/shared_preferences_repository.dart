import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants/shared_preferences_constants.dart';

class SharedPreferencesRepository {

  static SharedPreferences? _instance;

  static Future<void> initialize() async {
    if (_instance != null) {
      throw Exception('SharedPreferences is a singleton and has already been instantiated.');
    } else {
      _instance = await SharedPreferences.getInstance();
    }
  }

  static SharedPreferences get instance {
    if (_instance == null) {
      throw Exception('SharedPreferences has not been initialized.');
    }
    return _instance!;
  }

  // Function to save offline device IP to shared preferences
  static Future<void> saveOfflineDeviceIp(String ip) async {
    final List<String> ips = instance.getStringList(SharedPreferencesConstants.offlineDeviceIpsKey) ?? [];
    if (!ips.contains(ip)) {
      ips.add(ip);
      await instance.setStringList(SharedPreferencesConstants.offlineDeviceIpsKey, ips);
    }
  }

  // Function to delete offline device IP from shared preferences
  static Future<void> deleteOfflineDeviceIp(String ip) async {
    final List<String> ips = instance.getStringList(SharedPreferencesConstants.offlineDeviceIpsKey) ?? [];
    if (ips.contains(ip)) {
      ips.remove(ip);
      await instance.setStringList(SharedPreferencesConstants.offlineDeviceIpsKey, ips);
    }
  }

  // Function to get all offline device IPs from shared preferences
  static List<String> getOfflineDeviceIps() {
    return instance.getStringList(SharedPreferencesConstants.offlineDeviceIpsKey) ?? [];
  }

}