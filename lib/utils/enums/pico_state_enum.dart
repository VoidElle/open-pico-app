enum PicoStateEnum {

  HEAT_RECOVERY,

  EXTRACTION,

  IMMISSION,

  // Humidity modes
  HUMIDITY_MODE_RECOVERY,
  HUMIDITY_MODE_EXTRACTION,

  // Humidity - CO2 modes
  HUMIDITY_CO2_MODE_RECOVERY,
  HUMIDITY_CO2_MODE_EXTRACTION,

  // Comfort modes
  COMFORT_SUMMER,
  COMFORT_WINTER,

  NATURAL_VENTILATION,

  // CO2 modes
  CO2_MODE_RECOVERY,
  CO2_MODE_EXTRACTION
}

class PicoStateEnumUtils {

  static PicoStateEnum getPicoStateEnumFromMod(int mod) {
    switch (mod) {
      case 1:
        return PicoStateEnum.HEAT_RECOVERY;
      case 2:
        return PicoStateEnum.EXTRACTION;
      case 3:
        return PicoStateEnum.IMMISSION;
      case 4:
        return PicoStateEnum.HUMIDITY_MODE_RECOVERY;
      case 5:
        return PicoStateEnum.HUMIDITY_MODE_EXTRACTION;
      case 6:
        return PicoStateEnum.COMFORT_SUMMER;
      case 7:
        return PicoStateEnum.COMFORT_WINTER;
      case 8:
        return PicoStateEnum.CO2_MODE_RECOVERY;
      case 9:
        return PicoStateEnum.CO2_MODE_EXTRACTION;
      case 10:
        return PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY;
      case 11:
        return PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION;
      case 12:
        return PicoStateEnum.NATURAL_VENTILATION;
    }
    throw new Exception("Cannot find a mode for $mod");
  }

  static int getModFromPicoStateEnum(PicoStateEnum picoStateEnum) {
    switch (picoStateEnum) {
      case PicoStateEnum.HEAT_RECOVERY:
        return 1;
      case PicoStateEnum.EXTRACTION:
        return 2;
      case PicoStateEnum.IMMISSION:
        return 3;
      case PicoStateEnum.HUMIDITY_MODE_RECOVERY:
        return 4;
      case PicoStateEnum.HUMIDITY_MODE_EXTRACTION:
        return 5;
      case PicoStateEnum.COMFORT_SUMMER:
        return 6;
      case PicoStateEnum.COMFORT_WINTER:
        return 7;
      case PicoStateEnum.CO2_MODE_RECOVERY:
        return 8;
      case PicoStateEnum.CO2_MODE_EXTRACTION:
        return 9;
      case PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY:
        return 10;
      case PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION:
        return 11;
      case PicoStateEnum.NATURAL_VENTILATION:
        return 12;
    }
  }

}