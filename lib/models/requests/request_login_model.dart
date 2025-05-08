import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_login_model.freezed.dart';
part 'request_login_model.g.dart';

@freezed
abstract class RequestLoginModel with _$RequestLoginModel {

  const factory RequestLoginModel({

    @JsonKey(name: 'DeviceId')
    required String deviceId,

    @JsonKey(name: 'Platform')
    required String platform,

    @JsonKey(name: 'Password')
    required String password,

    @JsonKey(name: 'TokenPush')
    required String tokenPush,

    @JsonKey(name: 'Username')
    required String username,

  }) = _RequestLoginModel;

  factory RequestLoginModel.fromJson(Map<String, Object?> json) => _$RequestLoginModelFromJson(json);
}