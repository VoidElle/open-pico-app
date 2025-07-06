import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/common_response_wrapper.freezed.dart';
part 'generated/common_response_wrapper.g.dart';

@freezed
abstract class CommonResponseWrapper with _$CommonResponseWrapper {

  const factory CommonResponseWrapper({

    @JsonKey(name: 'ResCode')
    required int resCode,

    @JsonKey(name: 'ResDescr')
    required String resDescr,

  }) = _CommonResponseWrapper;

  factory CommonResponseWrapper.fromJson(Map<String, Object?> json) => _$CommonResponseWrapperFromJson(json);
}