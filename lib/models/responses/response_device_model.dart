import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/response_device_model.freezed.dart';
part 'generated/response_device_model.g.dart';

@freezed
abstract class ResponseDeviceModel with _$ResponseDeviceModel {

  const factory ResponseDeviceModel({

    @JsonKey(name: 'LVDV_Type')
    required int? lvdvType,

    @JsonKey(name: 'LVDV_Id')
    required int? lvdvId,

    @JsonKey(name: 'DevId')
    required int? deviceId,

    @JsonKey(name: 'Serial')
    required String serial,

    @JsonKey(name: 'Name')
    required String name,

    @JsonKey(name: 'FWVer')
    required String firmwareVersion,

    @JsonKey(name: 'OperatingMode')
    required int operatingMode,

    @JsonKey(name: 'IsOff')
    required bool isOff,

    @JsonKey(name: 'LastConfigUpd')
    required String? lastConfigurationUpdate,

    @JsonKey(name: 'LastSyncUpd')
    required String? lastSyncUpdate,

    @JsonKey(name: 'LastAddTimezone')
    required String? LastAddTimezone,

    @JsonKey(name: 'NUM_ERROR')
    required int? numberOfErrors,

  }) = _ResponseDeviceModel;

  factory ResponseDeviceModel.fromJson(Map<String, Object?> json) => _$ResponseDeviceModelFromJson(json);
}