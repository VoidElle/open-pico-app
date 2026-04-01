/// Model representing a zone (room) in a CU/Polaris device.
///
/// Cloud API (GetHome) returns zones in a "Zones" JSON array where each zone
/// uses Gson-style field names matching the official Java model:
///   ZoneId (int), Name (String), Temp (String as int/10), SetTemp (String as int/10),
///   isOff (bool), Fancoil (int), FancoilSet (int), EV (int), Serranda (int),
///   SerrandaSet (int), ManCrono (int), CBadge (Object), CWin (Object),
///   Umd (String), SetUmd (String), isCronoMode (bool), isMaster (bool),
///   toconvertError (int), numError (int), coff (bool)
///
/// Temperatures come as integer strings (e.g. "195" = 19.5°C, "200" = 20.0°C).
class ZonaModel {
  final int? zoneId;
  final String name;
  final double? currentTemp;
  final double? setTemp;
  final bool isOff;
  final bool isCooling;
  final int? fancoil;
  final int? fancoilSet;
  final int? ev;
  final int? serranda;
  final int? serrandaSet;
  final int? manCrono;
  final bool isCronoMode;
  final bool isMaster;
  final double? humidity;
  final double? setHumidity;
  final int? numError;
  final dynamic cBadge;
  final dynamic cWin;

  /// Raw JSON data for debugging
  final Map<String, dynamic> rawData;

  ZonaModel({
    this.zoneId,
    required this.name,
    this.currentTemp,
    this.setTemp,
    this.isOff = false,
    this.isCooling = false,
    this.fancoil,
    this.fancoilSet,
    this.ev,
    this.serranda,
    this.serrandaSet,
    this.manCrono,
    this.isCronoMode = false,
    this.isMaster = false,
    this.humidity,
    this.setHumidity,
    this.numError,
    this.cBadge,
    this.cWin,
    required this.rawData,
  });

  bool get isOn => !isOff;
  bool get hasError => numError != null && numError! > 0;

  /// Factory to parse zone from GetHome cloud response (Gson-style field names).
  /// Temperatures are divided by 10 (server sends "195" for 19.5°C).
  factory ZonaModel.fromJson(Map<String, dynamic> json) {
    // Parse temperature: try as number first, then as string-encoded integer/10
    double? parseTemp(dynamic value) {
      if (value == null) return null;
      if (value is num) return value / 10.0;
      if (value is String) {
        final d = double.tryParse(value);
        if (d == null) return null;
        // If the value is >= 100, it's likely an integer encoding (e.g. "195" = 19.5)
        // If it's already decimal (e.g. "19.5"), use as-is
        if (d >= 100 || d <= -100) return d / 10.0;
        return d;
      }
      return null;
    }

    return ZonaModel(
      zoneId: _parseInt(json['ZoneId'] ?? json['zoneId'] ?? json['id_zona']),
      name: (json['Name'] ?? json['name'] ?? 'Unknown').toString(),
      currentTemp: parseTemp(json['Temp'] ?? json['temp'] ?? json['t']),
      setTemp: parseTemp(json['SetTemp'] ?? json['setTemp'] ?? json['t_set']),
      isOff: _parseBool(json['IsOFF'] ?? json['isOff'] ?? json['IsOff'] ?? json['is_off'], false),
      isCooling: _parseBool(json['isCooling'] ?? json['IsCooling'] ?? json['is_cool'], false),
      fancoil: _parseInt(json['Fancoil'] ?? json['fancoil'] ?? json['fan']),
      fancoilSet: _parseInt(json['FancoilSet'] ?? json['fancoilSet'] ?? json['fan_set']),
      ev: _parseInt(json['EV'] ?? json['ev']),
      serranda: _parseInt(json['Serranda'] ?? json['serranda'] ?? json['shu']),
      serrandaSet: _parseInt(json['SerrandaSet'] ?? json['serrandaSet'] ?? json['shu_set']),
      manCrono: _parseInt(json['ManCrono'] ?? json['manCrono']),
      isCronoMode: _parseBool(json['isCronoMode'] ?? json['IsCronoMode'] ?? json['is_crono'], false),
      isMaster: _parseBool(json['isMaster'] ?? json['IsMaster'], false),
      humidity: parseTemp(json['Umd'] ?? json['umd'] ?? json['u']),
      setHumidity: parseTemp(json['SetUmd'] ?? json['setUmd'] ?? json['u_set']),
      numError: _parseInt(json['numError'] ?? json['NumError'] ?? json['toconvertError']),
      cBadge: json['CBadge'] ?? json['c_badge'],
      cWin: json['CWin'] ?? json['c_win'],
      rawData: json,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  @override
  String toString() => 'ZonaModel(id: $zoneId, name: $name, temp: $currentTemp, '
      'setTemp: $setTemp, isOff: $isOff)';
}
