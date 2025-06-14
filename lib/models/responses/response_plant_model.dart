import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_pico_app/models/responses/response_device_model.dart';

part 'response_plant_model.freezed.dart';
part 'response_plant_model.g.dart';

@freezed
abstract class ResponsePlantModel with _$ResponsePlantModel {

  const factory ResponsePlantModel({

    @JsonKey(name: 'LVPL_Id')
    required int? lvplType,

    @JsonKey(name: 'LVPL_Name')
    required String? lvplName,

    @JsonKey(name: 'LVPL_USAN_Id')
    required int? lvplUsanId,

    @JsonKey(name: 'LVPL_Icon')
    required int? lvplIcon,

    @JsonKey(name: 'ListDevices')
    @Default(<ResponseDeviceModel>[])
    List<ResponseDeviceModel> devicesList,

  }) = _ResponsePlantModel;

  factory ResponsePlantModel.fromJson(Map<String, Object?> json) => _$ResponsePlantModelFromJson(json);
}