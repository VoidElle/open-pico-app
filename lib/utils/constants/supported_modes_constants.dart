import '../enums/pico_state_enum.dart';

class SupportedModesConstants {

  // Preset modes that support fan speed changes
  static const List<PicoStateEnum> fanSpeedSupportedPresetModes = [
    PicoStateEnum.HEAT_RECOVERY,
    PicoStateEnum.EXTRACTION,
    PicoStateEnum.IMMISSION,
    PicoStateEnum.COMFORT_SUMMER,
    PicoStateEnum.COMFORT_WINTER,
  ];

  // Preset modes that support humidity selector changes
  static const List<PicoStateEnum> humiditySelectSupportedPresetModes = [
    PicoStateEnum.HUMIDITY_MODE_RECOVERY,
    PicoStateEnum.HUMIDITY_MODE_EXTRACTION,
    PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY,
    PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION,
  ];

}