
import 'package:flutter/material.dart';

class AddIpAddressBottomSheet extends StatefulWidget {
  const AddIpAddressBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddIpAddressBottomSheet> createState() => _AddIpAddressBottomSheetState();
}

class _AddIpAddressBottomSheetState extends State<AddIpAddressBottomSheet> {
  final TextEditingController _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  // Simple IP address validation
  String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    final ipRegex = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    );

    if (!ipRegex.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }

    final parts = value.split('.');
    for (var part in parts) {
      final num = int.parse(part);
      if (num < 0 || num > 255) {
        return 'IP segments must be between 0-255';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Add a device',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // IP Address Input
            TextFormField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              validator: _validateIP,
              autofocus: true,
            ),
            const SizedBox(height: 24),

            // Buttons Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),

                // Add Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Return the IP address to the caller
                        Navigator.pop(context, _ipController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}