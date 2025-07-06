import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/models/internal/internal_grid_icon_label_cta_model.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';

import '../widgets/common/grid_icon_label_cta_item.dart';

class PicoStatusPage extends StatelessWidget {

  const PicoStatusPage({
    required this.deviceStatus,
    super.key,
  });

  final DeviceStatus deviceStatus;

  static const String route = '/pico-status';

  @override
  Widget build(BuildContext context) {

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
        onTap: () {},
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
          deviceStatus.name,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "VMC é attualmente ${deviceStatus.isDeviceOn ? "ACCESO" : "SPENTO"}",
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