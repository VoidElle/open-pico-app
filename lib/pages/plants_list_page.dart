import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/models/responses/response_plant_model.dart';
import 'package:open_pico_app/utils/parsers/plants_responses_parser.dart';
import 'package:open_pico_app/widgets/plants_list/plants_list_appbar.dart';

import '../models/responses/response_device_model.dart';
import '../models/responses/response_plant_model_wrapper_parsed.dart';

class PlantsListPage extends ConsumerStatefulWidget {

  const PlantsListPage({super.key});

  static const String route = '/plants-list';

  @override
  ConsumerState<PlantsListPage> createState() => _DevicesListPageState();
}

class _DevicesListPageState extends ConsumerState<PlantsListPage> {

  // Future that retrieves the list of plants using the PlantsResponsesParser
  late Future<ResponsePlantModelWrapperParsed> _retrievePlantsFuture;

  @override
  void initState() {
    _retrievePlantsFuture = PlantsResponsesParser.retrievePlantsParsed(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlantsListAppbar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildPlantsList(),
        ],
      ),
    );
  }

  // Builds the list of plants using a FutureBuilder to handle asynchronous data retrieval
  // This method returns a widget that displays the list of plants or an error/loading state
  Widget _buildPlantsList() {
    return FutureBuilder(
      future: _retrievePlantsFuture,
      builder: (BuildContext context, AsyncSnapshot<ResponsePlantModelWrapperParsed> snapshot) {

        // If the connection is still waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // If an error occurs, display the error message
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        // If the snapshot has no data or the data is empty, show a message
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'No devices found.',
            ),
          );
        }

        // Retrieve the list of plants from the snapshot data
        final List<ResponsePlantModel> plants = snapshot.data!.resDescr;

        // Render the list of plants using a ListView
        return ListView.builder(
          shrinkWrap: true,
          itemCount: plants.length,
          itemBuilder: (BuildContext context, int index) {
            final ResponsePlantModel plant = plants[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListTile(
                title: Text(
                  plant.lvplName != null
                      ? "${plant.lvplName} (ID: ${plant.lvplUsanId ?? 'N/A'})"
                      : 'Unknown Plant',
                ),
                subtitle: _buildDevicesList(plant.devicesList),
              ),
            );
          },
        );
      },
    );
  }

  // Method to build the list of devices for a given plant
  // It returns a widget that displays the devices or a message if no devices are found
  Widget _buildDevicesList(List<ResponseDeviceModel> devicesList) {

    // If the devices list is empty, return a message indicating no devices found
    if (devicesList.isEmpty) {
      return const Text('No devices found for this plant.');
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: devicesList.map((ResponseDeviceModel device) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  Icons.hvac,
                  size: 32,
                ),
              ),
              title: Text(
                device.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'ID: ${device.deviceId ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () async {
                final DeviceStatus deviceStatus = await PlantsResponsesParser.retrieveSpecificPlantParsed(ref, device.serial, "1234");
                print(deviceStatus);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

}
