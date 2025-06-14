import 'package:flutter/material.dart';
import 'package:open_pico_app/models/responses/response_plant_model.dart';

class DeviceDetailPage extends StatelessWidget {

  const DeviceDetailPage({
    required this.responsePlantModel,
    super.key,
  });

  final ResponsePlantModel responsePlantModel;

  static const String route = '/device-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [



        ],
      ),
    );
  }

}
