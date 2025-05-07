// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InternalUserModel _$InternalUserModelFromJson(Map<String, dynamic> json) =>
    _InternalUserModel(
      resCode: (json['ResCode'] as num).toInt(),
      id: (json['ID'] as num).toInt(),
      token: json['Token'] as String,
    );

Map<String, dynamic> _$InternalUserModelToJson(_InternalUserModel instance) =>
    <String, dynamic>{
      'ResCode': instance.resCode,
      'ID': instance.id,
      'Token': instance.token,
    };
