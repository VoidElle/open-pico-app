import 'package:flutter/material.dart';
import 'package:open_pico_app/models/responses/device_status.dart';

class PicoStatusPage extends StatelessWidget {

  const PicoStatusPage({
    required this.deviceStatus,
    super.key,
  });

  final DeviceStatus deviceStatus;

  static const String route = '/pico-status';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

}
