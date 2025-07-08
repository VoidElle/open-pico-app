import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/models/internal/internal_grid_icon_label_cta_model.dart';
import 'package:open_pico_app/models/responses/common_response_wrapper.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/utils/command_utils.dart';

import '../models/props/pico_status_page_props.dart';
import '../models/responses/response_device_model.dart';
import '../repositories/secure_storage_repository.dart';
import '../use_cases/pico/pico_execute_command_usecase.dart';
import '../use_cases/secure_storage/secure_storage_write_read_device_pin_usecase.dart';
import '../widgets/common/grid_icon_label_cta_item.dart';

class PicoStatusPage extends ConsumerWidget {

  const PicoStatusPage({
    required this.picoStatusPageProps,
    super.key,
  });

  final PicoStatusPageProps picoStatusPageProps;

  static const String route = '/pico-status';

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final DeviceStatus deviceStatus = picoStatusPageProps.deviceStatus;
    final ResponseDeviceModel responseDeviceModel = picoStatusPageProps.responseDeviceModel;

    final List<InternalGridIconLabelCtaModel> items = <InternalGridIconLabelCtaModel>[
      InternalGridIconLabelCtaModel(
        text: 'Recupero di calore',
        iconData: Icons.hot_tub,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Estrazione',
        iconData: Icons.arrow_back,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Immissione',
        iconData: Icons.arrow_right_alt,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá umiditá',
        iconData: Icons.heat_pump_sharp,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'ON / OFF',
        iconData: Icons.settings_remote,
        onTap: () async {

          // Retrieve the PIN from the Secure Storage
          final SecureStorageWriteReadDevicePinUsecase secureStorageWriteReadDevicePinUsecase = SecureStorageWriteReadDevicePinUsecase(SecureStorageRepository.instance);
          final Map<String, dynamic> data = await secureStorageWriteReadDevicePinUsecase.readData(responseDeviceModel.serial);

          // Get the PIN from the retrieved data
          final String devicePin = data['pin'];

          final String command = CommandUtils
              .getOnOffCmd(!deviceStatus.isDeviceOn, devicePin);

          final PicoExecuteCommandUsecase picoExecuteCommandUsecase = ref
              .read(getPicoExecuteCommandUsecaseProvider);

          final CommonResponseWrapper response = await picoExecuteCommandUsecase
              .execute(
                command: command,
                deviceName: deviceStatus.name,
                devicePin: devicePin,
                deviceSerial: responseDeviceModel.serial,
              );

          debugPrint(response.toString());
        },
        selected: deviceStatus.isDeviceOn,
        borderColor: deviceStatus.isDeviceOn
            ? Colors.green
            : Colors.red,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá CO2 / Umiditiá',
        iconData: Icons.heat_pump_rounded,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Comfort',
        iconData: Icons.person,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Ventilazione naturale',
        iconData: Icons.forest,
        onTap: () {},
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá CO2',
        iconData: Icons.co2,
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(PlantsListPage.route),
        ),
        title: Text(
          picoStatusPageProps.deviceStatus.name,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "VMC é attualmente ${picoStatusPageProps.deviceStatus.isDeviceOn ? "ACCESO" : "SPENTO"}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: items.map((InternalGridIconLabelCtaModel item) {
                return GridIconLabelCtaItem(
                  internalGridIconLabelCtaModel: item,
                );
              }).toList(),
            ),
          ),

        ],
      ),
    );
  }

}