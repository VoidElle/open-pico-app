import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_pico_app/models/responses/response_plant_model.dart';

part 'response_plant_model_wrapper_parsed.freezed.dart';
part 'response_plant_model_wrapper_parsed.g.dart';

@freezed
abstract class ResponsePlantModelWrapperParsed with _$ResponsePlantModelWrapperParsed {

  const factory ResponsePlantModelWrapperParsed({

    @JsonKey(name: 'ResCode')
    required int resCode,

    @JsonKey(name: 'ResDescr')
    required List<ResponsePlantModel> resDescr,

  }) = _ResponsePlantModelWrapperParsed;

  factory ResponsePlantModelWrapperParsed.fromJson(Map<String, Object?> json) => _$ResponsePlantModelWrapperParsedFromJson(json);
}