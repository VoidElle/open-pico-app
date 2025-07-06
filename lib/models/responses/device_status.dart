import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';
import 'last_packet.dart';

part 'generated/device_status.freezed.dart';
part 'generated/device_status.g.dart';

@freezed
abstract class DeviceStatus with _$DeviceStatus {
  const factory DeviceStatus({
    required String cmd,
    required String frm,
    required String ip,
    @JsonKey(name: 'fw_ver') required String fwVer,
    required int vr,
    dynamic reset,
    @JsonKey(name: 'w_rssi') required int wRssi,
    @JsonKey(name: 'on_off') required int onOff,
    required int mod,
    required int speed,
    @JsonKey(name: 'spd_row') required int spdRow,
    @JsonKey(name: 'spd_rich') required int spdRich,
    @JsonKey(name: 'night_mod') required int nightMod,
    @JsonKey(name: 's_umd') required int sUmd,
    @JsonKey(name: 'id_slave') required int idSlave,
    required String name,
    @JsonKey(name: 'led_on_off') required int ledOnOff,
    @JsonKey(name: 'led_on_off_breve') required int ledOnOffBreve,
    @JsonKey(name: 'led_color') required int ledColor,
    @JsonKey(name: 'has_slave') required int hasSlave,
    required int res,
    @JsonKey(name: 'lastpk') required String lastpk,
    dynamic timezone,
    @Default([]) List<List<dynamic>> err,
    @Default([]) List<int> man,
    @JsonKey(name: 'par_ext') @Default([]) List<int> parExt,
    @JsonKey(name: 'par_amb') @Default([]) List<int> parAmb,
    @JsonKey(name: 'm_crono') required int mCrono,
    @JsonKey(name: 'tw_active') required int twActive,
  }) = _DeviceStatus;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) =>
      _$DeviceStatusFromJson(json);
}

// Extension methods for better usability
extension DeviceStatusExtension on DeviceStatus {
  bool get isDeviceOn => onOff == 1;
  bool get isLedOn => ledOnOff == 1;
  bool get hasSlaveDevice => hasSlave == 1;
  bool get isNightMode => nightMod > 0;

  // Parse the nested lastpk JSON string
  LastPacket get parsedLastpk {
    final Map<String, dynamic> jsonMap = jsonDecode(lastpk);
    return LastPacket.fromJson(jsonMap);
  }
}