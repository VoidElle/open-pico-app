import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/request_command_model.freezed.dart';
part 'generated/request_command_model.g.dart';

@freezed
abstract class RequestCommandModel with _$RequestCommandModel {

  const factory RequestCommandModel({

    @JsonKey(name: 'Cmd')
    required String command,

    @JsonKey(name: 'Name')
    required String deviceName,

    @JsonKey(name: 'Pin')
    required String devicePin,

    @JsonKey(name: 'Serial')
    required String deviceSerial,

  }) = _RequestCommandModel;

  factory RequestCommandModel.fromJson(Map<String, Object?> json) => _$RequestCommandModelFromJson(json);
}