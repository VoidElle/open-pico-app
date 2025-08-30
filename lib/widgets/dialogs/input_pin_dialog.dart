import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InputPinDialog {

  static Future<String?> show(BuildContext context, bool previousPinError) {

    final TextEditingController pinController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tr("input_pin_modal.title"),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr("input_pin_modal.label"),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr("input_pin_modal.enter_pin_label");
                    }
                    return null;
                  },
                ),

                if (previousPinError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      tr("input_pin_modal.pin_invalid_label"),
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                tr("input_pin_modal.cancel_button"),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(pinController.text);
                }
              },
              child: Text(
                tr("input_pin_modal.confirm_button"),
              ),
            ),

          ],
        );
      },
    );
  }

}