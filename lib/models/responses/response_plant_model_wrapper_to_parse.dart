import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_plant_model_wrapper_to_parse.freezed.dart';
part 'response_plant_model_wrapper_to_parse.g.dart';

@freezed
abstract class ResponsePlantModelWrapperToParse with _$ResponsePlantModelWrapperToParse {

  const factory ResponsePlantModelWrapperToParse({

    @JsonKey(name: 'ResCode')
    required int resCode,

    @JsonKey(name: 'ResDescr')
    required String resDescr,

  }) = _ResponsePlantModelWrapperToParse;

  factory ResponsePlantModelWrapperToParse.fromJson(Map<String, Object?> json) => _$ResponsePlantModelWrapperToParseFromJson(json);
}