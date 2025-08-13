import 'package:open_pico_app/utils/enums/pico_state_enum.dart';

class CommandUtils {

  static String getOnOffCmd(bool on, String pin) {
    return "{\"on_off\":${on ? 1 : 2},\"cmd\":\"upd_pico\",\"frm\":\"mqtt\",\"idp\":${on ? 2 : 1},\"pin\":\"${pin}\"}";
  }

  static String getCmdFromPicoState(PicoStateEnum picoStateEnum, String pin) {
    final int getMod = PicoStateEnumUtils.getModFromPicoStateEnum(picoStateEnum);
    return "{\"mod\":${getMod},\"on_off\":1,\"cmd\":\"upd_pico\",\"frm\":\"mqtt\",\"idp\":0,\"pin\":\"${pin}\"}";
  }

}