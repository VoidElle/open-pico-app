import 'package:freezed_annotation/freezed_annotation.dart';

part 'internal_user_model.freezed.dart';
part 'internal_user_model.g.dart';

@freezed
abstract class InternalUserModel with _$InternalUserModel {

  const factory InternalUserModel({

    @JsonKey(name: 'ResCode')
    required int resCode,

    @JsonKey(name: 'ID')
    required int id,

    @JsonKey(name: 'Token')
    required String token,

  }) = _InternalUserModel;

  factory InternalUserModel.fromJson(Map<String, Object?> json) => _$InternalUserModelFromJson(json);
}