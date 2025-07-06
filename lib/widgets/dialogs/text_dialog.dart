import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TextDialog {

  static Future<void> show({
    required BuildContext context,
    required String message,
    required String title,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

}