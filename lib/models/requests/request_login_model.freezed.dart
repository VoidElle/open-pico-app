// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_login_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestLoginModel {

@JsonKey(name: 'DeviceId') String get deviceId;@JsonKey(name: 'Platform') String get platform;@JsonKey(name: 'Password') String get password;@JsonKey(name: 'TokenPush') String get tokenPush;@JsonKey(name: 'Username') String get username;
/// Create a copy of RequestLoginModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestLoginModelCopyWith<RequestLoginModel> get copyWith => _$RequestLoginModelCopyWithImpl<RequestLoginModel>(this as RequestLoginModel, _$identity);

  /// Serializes this RequestLoginModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestLoginModel&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.password, password) || other.password == password)&&(identical(other.tokenPush, tokenPush) || other.tokenPush == tokenPush)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,platform,password,tokenPush,username);

@override
String toString() {
  return 'RequestLoginModel(deviceId: $deviceId, platform: $platform, password: $password, tokenPush: $tokenPush, username: $username)';
}


}

/// @nodoc
abstract mixin class $RequestLoginModelCopyWith<$Res>  {
  factory $RequestLoginModelCopyWith(RequestLoginModel value, $Res Function(RequestLoginModel) _then) = _$RequestLoginModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'DeviceId') String deviceId,@JsonKey(name: 'Platform') String platform,@JsonKey(name: 'Password') String password,@JsonKey(name: 'TokenPush') String tokenPush,@JsonKey(name: 'Username') String username
});




}
/// @nodoc
class _$RequestLoginModelCopyWithImpl<$Res>
    implements $RequestLoginModelCopyWith<$Res> {
  _$RequestLoginModelCopyWithImpl(this._self, this._then);

  final RequestLoginModel _self;
  final $Res Function(RequestLoginModel) _then;

/// Create a copy of RequestLoginModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? platform = null,Object? password = null,Object? tokenPush = null,Object? username = null,}) {
  return _then(_self.copyWith(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,tokenPush: null == tokenPush ? _self.tokenPush : tokenPush // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RequestLoginModel implements RequestLoginModel {
  const _RequestLoginModel({@JsonKey(name: 'DeviceId') required this.deviceId, @JsonKey(name: 'Platform') required this.platform, @JsonKey(name: 'Password') required this.password, @JsonKey(name: 'TokenPush') required this.tokenPush, @JsonKey(name: 'Username') required this.username});
  factory _RequestLoginModel.fromJson(Map<String, dynamic> json) => _$RequestLoginModelFromJson(json);

@override@JsonKey(name: 'DeviceId') final  String deviceId;
@override@JsonKey(name: 'Platform') final  String platform;
@override@JsonKey(name: 'Password') final  String password;
@override@JsonKey(name: 'TokenPush') final  String tokenPush;
@override@JsonKey(name: 'Username') final  String username;

/// Create a copy of RequestLoginModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestLoginModelCopyWith<_RequestLoginModel> get copyWith => __$RequestLoginModelCopyWithImpl<_RequestLoginModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestLoginModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestLoginModel&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.password, password) || other.password == password)&&(identical(other.tokenPush, tokenPush) || other.tokenPush == tokenPush)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,platform,password,tokenPush,username);

@override
String toString() {
  return 'RequestLoginModel(deviceId: $deviceId, platform: $platform, password: $password, tokenPush: $tokenPush, username: $username)';
}


}

/// @nodoc
abstract mixin class _$RequestLoginModelCopyWith<$Res> implements $RequestLoginModelCopyWith<$Res> {
  factory _$RequestLoginModelCopyWith(_RequestLoginModel value, $Res Function(_RequestLoginModel) _then) = __$RequestLoginModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'DeviceId') String deviceId,@JsonKey(name: 'Platform') String platform,@JsonKey(name: 'Password') String password,@JsonKey(name: 'TokenPush') String tokenPush,@JsonKey(name: 'Username') String username
});




}
/// @nodoc
class __$RequestLoginModelCopyWithImpl<$Res>
    implements _$RequestLoginModelCopyWith<$Res> {
  __$RequestLoginModelCopyWithImpl(this._self, this._then);

  final _RequestLoginModel _self;
  final $Res Function(_RequestLoginModel) _then;

/// Create a copy of RequestLoginModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? platform = null,Object? password = null,Object? tokenPush = null,Object? username = null,}) {
  return _then(_RequestLoginModel(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,tokenPush: null == tokenPush ? _self.tokenPush : tokenPush // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
