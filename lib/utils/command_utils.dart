class CommandUtils {

  static String getOnOffCmd(bool on, String pin) {
    return "{\"on_off\":${on ? 1 : 2},\"cmd\":\"upd_pico\",\"frm\":\"mqtt\",\"idp\":${on ? 2 : 1},\"pin\":\"1234\"}";
  }

}