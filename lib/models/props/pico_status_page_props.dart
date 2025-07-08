import 'package:freezed_annotation/freezed_annotation.dart';

import '../responses/device_status.dart';
import '../responses/response_device_model.dart';

part 'generated/pico_status_page_props.freezed.dart';

@freezed
abstract class PicoStatusPageProps with _$PicoStatusPageProps {

  const factory PicoStatusPageProps({
    required DeviceStatus deviceStatus,
    required ResponseDeviceModel responseDeviceModel,
  }) = _PicoStatusPageProps;

}