// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'internal_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InternalUserModel {

@JsonKey(name: 'ResCode') int get resCode;@JsonKey(name: 'ID') int get id;@JsonKey(name: 'Token') String get token;
/// Create a copy of InternalUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InternalUserModelCopyWith<InternalUserModel> get copyWith => _$InternalUserModelCopyWithImpl<InternalUserModel>(this as InternalUserModel, _$identity);

  /// Serializes this InternalUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InternalUserModel&&(identical(other.resCode, resCode) || other.resCode == resCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,resCode,id,token);

@override
String toString() {
  return 'InternalUserModel(resCode: $resCode, id: $id, token: $token)';
}


}

/// @nodoc
abstract mixin class $InternalUserModelCopyWith<$Res>  {
  factory $InternalUserModelCopyWith(InternalUserModel value, $Res Function(InternalUserModel) _then) = _$InternalUserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ResCode') int resCode,@JsonKey(name: 'ID') int id,@JsonKey(name: 'Token') String token
});




}
/// @nodoc
class _$InternalUserModelCopyWithImpl<$Res>
    implements $InternalUserModelCopyWith<$Res> {
  _$InternalUserModelCopyWithImpl(this._self, this._then);

  final InternalUserModel _self;
  final $Res Function(InternalUserModel) _then;

/// Create a copy of InternalUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resCode = null,Object? id = null,Object? token = null,}) {
  return _then(_self.copyWith(
resCode: null == resCode ? _self.resCode : resCode // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _InternalUserModel implements InternalUserModel {
  const _InternalUserModel({@JsonKey(name: 'ResCode') required this.resCode, @JsonKey(name: 'ID') required this.id, @JsonKey(name: 'Token') required this.token});
  factory _InternalUserModel.fromJson(Map<String, dynamic> json) => _$InternalUserModelFromJson(json);

@override@JsonKey(name: 'ResCode') final  int resCode;
@override@JsonKey(name: 'ID') final  int id;
@override@JsonKey(name: 'Token') final  String token;

/// Create a copy of InternalUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InternalUserModelCopyWith<_InternalUserModel> get copyWith => __$InternalUserModelCopyWithImpl<_InternalUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InternalUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InternalUserModel&&(identical(other.resCode, resCode) || other.resCode == resCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,resCode,id,token);

@override
String toString() {
  return 'InternalUserModel(resCode: $resCode, id: $id, token: $token)';
}


}

/// @nodoc
abstract mixin class _$InternalUserModelCopyWith<$Res> implements $InternalUserModelCopyWith<$Res> {
  factory _$InternalUserModelCopyWith(_InternalUserModel value, $Res Function(_InternalUserModel) _then) = __$InternalUserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ResCode') int resCode,@JsonKey(name: 'ID') int id,@JsonKey(name: 'Token') String token
});




}
/// @nodoc
class __$InternalUserModelCopyWithImpl<$Res>
    implements _$InternalUserModelCopyWith<$Res> {
  __$InternalUserModelCopyWithImpl(this._self, this._then);

  final _InternalUserModel _self;
  final $Res Function(_InternalUserModel) _then;

/// Create a copy of InternalUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resCode = null,Object? id = null,Object? token = null,}) {
  return _then(_InternalUserModel(
resCode: null == resCode ? _self.resCode : resCode // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
