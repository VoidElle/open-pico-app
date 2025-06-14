import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/response_user_model.freezed.dart';
part 'generated/response_user_model.g.dart';

@freezed
abstract class ResponseUserModel with _$ResponseUserModel {

  const factory ResponseUserModel({

    @JsonKey(name: 'ResCode')
    required int resCode,

    @JsonKey(name: 'ID')
    required int id,

    @JsonKey(name: 'Token')
    required String token,

  }) = _ResponseUserModel;

  factory ResponseUserModel.fromJson(Map<String, Object?> json) => _$ResponseUserModelFromJson(json);
}