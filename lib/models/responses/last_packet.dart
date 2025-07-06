import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/last_packet.freezed.dart';
part 'generated/last_packet.g.dart';

@freezed
abstract class LastPacket with _$LastPacket {
  const factory LastPacket({
    required int idp,
    required String frm,
    required String cmd,
    required String ip,
    @JsonKey(name: 'fw_ver') required String fwVer,
    @JsonKey(name: 'fw_note') required String fwNote,
    required int vr,
    required int modello,
    @JsonKey(name: 'BaseTop') required int baseTop,
    @JsonKey(name: 'Grd_DM') required String grdDM,
    @JsonKey(name: 'config_mod') required int configMod,
    @JsonKey(name: 'id_slave') required int idSlave,
    required String name,
    required int mod,
    @JsonKey(name: 'step_mod') required int stepMod,
    @JsonKey(name: 'on_off') required int onOff,
    required int speed,
    @JsonKey(name: 'spd_rich') required int spdRich,
    @JsonKey(name: 'spd_row') required int spdRow,
    @JsonKey(name: 'fan_dir') required int fanDir,
    required int verso,
    @JsonKey(name: 's_umd') required int sUmd,
    @JsonKey(name: 's_co2') required int sCo2,
    @JsonKey(name: 'umd_raw') required int umdRaw,
    @JsonKey(name: 'AMB_tmpr') required double ambTmpr,
    @JsonKey(name: 'Delta_tmprCiclo') required int deltaTmprCiclo,
    @JsonKey(name: 'Delta_umdCiclo') required int deltaUmdCiclo,
    @JsonKey(name: 'v_tmpr') required double vTmpr,
    @JsonKey(name: 'v_umd') required double vUmd,
    @JsonKey(name: 'v_AirQ') required int vAirQ,
    @JsonKey(name: 'v_Tvoc') required int vTvoc,
    @JsonKey(name: 'v_ECo2') required int vECo2,
    @JsonKey(name: 'par_rt') @Default([]) List<int> parRt,
    @JsonKey(name: 'par_mm') @Default([]) List<int> parMm,
    @JsonKey(name: 'par_amb') @Default([]) List<int> parAmb,
    @JsonKey(name: 'par_ext') @Default([]) List<int> parExt,
    @JsonKey(name: 'night_mod') required int nightMod,
    @JsonKey(name: 'led_on_off') required int ledOnOff,
    @JsonKey(name: 'led_on_off_breve') required int ledOnOffBreve,
    @JsonKey(name: 'led_color') required int ledColor,
    @JsonKey(name: 'm_crono') required int mCrono,
    @JsonKey(name: 'tw_active') required int twActive,
    @Default([]) List<List<dynamic>> err,
    @Default([]) List<int> man,
    @JsonKey(name: 'has_slave') required int hasSlave,
    @JsonKey(name: 'bmp_slave') required int bmpSlave,
    required int cntr,
    required int memfree,
    @JsonKey(name: 'up_time') required int upTime,
    required String date,
    required String time,
    required int week,
    required int res,
  }) = _LastPacket;

  factory LastPacket.fromJson(Map<String, dynamic> json) =>
      _$LastPacketFromJson(json);
}

extension LastPacketExtension on LastPacket {
  bool get isDeviceOn => onOff == 1;
  bool get isLedOn => ledOnOff == 1;
  bool get hasSlaveDevice => hasSlave == 1;
  bool get isNightMode => nightMod > 0;
  bool get hasRTC => date != "NO RTC" && time != "NO RTC";

  String get memoryUsage => "${((memfree / 1024 / 1024) * 100).toStringAsFixed(1)}% free";

  Duration get upTimeDuration => Duration(milliseconds: upTime);

  String get formattedUpTime {
    final duration = upTimeDuration;
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    return "${days}d ${hours}h ${minutes}m";
  }
}