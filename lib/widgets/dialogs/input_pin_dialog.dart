import 'package:flutter/material.dart';

class InputPinDialog {

  static Future<String?> show(BuildContext context, bool previousPinError) {

    final TextEditingController pinController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PIN';
                    }
                    return null;
                  },
                ),

                if (previousPinError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Invalid PIN. Please try again.',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(pinController.text);
                }
              },
              child: const Text('Confirm'),
            ),

          ],
        );
      },
    );
  }

}