import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';
import 'device_status.dart';

part 'generated/device_status_response.freezed.dart';
part 'generated/device_status_response.g.dart';

@freezed
abstract class DeviceStatusResponse with _$DeviceStatusResponse {
  const factory DeviceStatusResponse({
    @JsonKey(name: 'ResDescr') required String resDescr,
  }) = _DeviceStatusResponse;

  factory DeviceStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceStatusResponseFromJson(json);
}

// Extension methods for better usability
extension DeviceStatusResponseExtension on DeviceStatusResponse {
  DeviceStatus get parsedResDescr {
    final Map<String, dynamic> jsonMap = jsonDecode(resDescr);
    return DeviceStatus.fromJson(jsonMap);
  }
}