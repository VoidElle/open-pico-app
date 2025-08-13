import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/dialogs/specific_pico_mode_selectable_dialog.dart';
import 'package:open_pico_app/models/internal/internal_grid_icon_label_cta_model.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/use_cases/status/execute_change_status_command_usecase.dart';
import 'package:open_pico_app/use_cases/status/retrieve_device_status_usecase.dart';
import 'package:open_pico_app/use_cases/utils/get_device_pin_usecase.dart';
import 'package:open_pico_app/utils/command_utils.dart';

import '../models/internal/internal_specific_pico_mode_selectable_model.dart';
import '../models/props/pico_status_page_props.dart';
import '../models/responses/response_device_model.dart';
import '../utils/enums/pico_state_enum.dart';
import '../widgets/common/grid_icon_label_cta_item.dart';

class PicoStatusPage extends ConsumerStatefulWidget {

  const PicoStatusPage({
    required this.picoStatusPageProps,
    super.key,
  });

  final PicoStatusPageProps picoStatusPageProps;

  static const String route = '/pico-status';

  @override
  ConsumerState<PicoStatusPage> createState() => _PicoStatusPageState();
}

class _PicoStatusPageState extends ConsumerState<PicoStatusPage> {

  // The following variables are used to manage the polling mechanism
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isExecutingStatusUpdate = false;

  // The current device status
  late DeviceStatus deviceStatus;

  // The device pin, which is retrieved once and used for subsequent commands
  String? devicePin;

  @override
  void initState() {

    super.initState();

    deviceStatus = widget.picoStatusPageProps.deviceStatus;
    _initializePolling();

  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // Function to initialize the polling mechanism
  Future<void> _initializePolling() async {
    try {

      final String deviceSerial = widget.picoStatusPageProps.responseDeviceModel.serial;

      // Get device pin once and store it
      devicePin = await ref
          .read(getGetDevicePinUsecaseProvider)
          .execute(deviceSerial: deviceSerial);

      _startPolling();

    } catch (e) {
      debugPrint('Error initializing polling: $e');
    }
  }

  // Function to start the polling timer
  void _startPolling() {

    if (_isPolling || devicePin == null) {
      return;
    }

    _isPolling = true;
    debugPrint('Started device status polling');

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {

      // Skip if previous execution is still running
      if (_isExecutingStatusUpdate) {
        debugPrint('Previous status update still running, skipping...');
        return;
      }

      await _updateDeviceStatus();

    });
  }

  // Function to stop the polling timer
  void _stopPolling() {

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;

    debugPrint('Stopped device status polling');
  }

  // Function to update the device status
  // This function will be called periodically to refresh the device status
  // and update the UI accordingly
  Future<void> _updateDeviceStatus() async {

    if (!mounted || devicePin == null) {
      return;
    }

    _isExecutingStatusUpdate = true;

    try {

      final String deviceSerial = widget.picoStatusPageProps.responseDeviceModel.serial;

      // Retrieve the specific PICO device status
      final DeviceStatus updatedDeviceStatus = await ref
          .read(getRetrieveDeviceStatusUsecaseProvider)
          .execute(deviceSerial: deviceSerial, devicePin: devicePin!);

      // Log the response
      debugPrint("Updated device status: ${updatedDeviceStatus.toJson()}");

      // Update the state only if widget is still mounted
      if (mounted) {
        setState(() => deviceStatus = updatedDeviceStatus);
      }

    } catch (e) {
      debugPrint('Error updating device status: $e');
    } finally {
      _isExecutingStatusUpdate = false;
    }
  }

  // Function to change the Pico mode, this function will be called when
  // the user taps on a specific mode
  Future<void> _changePicoMode(PicoStateEnum picoStateEnum) async {
    try {

      final ResponseDeviceModel responseDeviceModel = widget
          .picoStatusPageProps
          .responseDeviceModel;

      // Retrieve the device serial
      final String deviceSerial = responseDeviceModel.serial;

      // Retrieve the device pin
      final String devicePin = await ref
          .read(getGetDevicePinUsecaseProvider)
          .execute(deviceSerial: deviceSerial);

      // Retrieve the change mode command
      final String command = CommandUtils
          .getCmdFromPicoState(picoStateEnum, devicePin);

      // Execute the command
      await ref
          .read(getExecuteChangeStatusCommandUsecaseProvider)
          .execute(
            deviceStatus: deviceStatus,
            responseDeviceModel: responseDeviceModel,
            command: command,
          );

    } catch (e) {
      debugPrint('Error changing Pico mode: $e');
    }
  }

  // Function to execute the on / off command
  Future<void> _executeOnOffCommand() async {
    try {

      final ResponseDeviceModel responseDeviceModel = widget
          .picoStatusPageProps
          .responseDeviceModel;

      // Retrieve the device serial
      final String deviceSerial = responseDeviceModel.serial;

      // Retrieve the device pin
      final String devicePin = await ref
          .read(getGetDevicePinUsecaseProvider)
          .execute(deviceSerial: deviceSerial);

      // Retrieve the command ON or OFF
      final String command = CommandUtils
          .getOnOffCmd(!deviceStatus.isDeviceOn, devicePin);

      // Execute the command
      await ref
          .read(getExecuteChangeStatusCommandUsecaseProvider)
          .execute(
            deviceStatus: deviceStatus,
            responseDeviceModel: responseDeviceModel,
            command: command,
          );

    } catch (e) {
      debugPrint('Error executing ON/OFF command: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final int currentModToParse = deviceStatus.mod;
    final PicoStateEnum currentPicoState = PicoStateEnumUtils.getPicoStateEnumFromMod(currentModToParse);

    final List<InternalGridIconLabelCtaModel> items = <InternalGridIconLabelCtaModel>[
      InternalGridIconLabelCtaModel(
        text: 'Recupero di calore',
        iconData: Icons.hot_tub,
        onTap: () => _changePicoMode(PicoStateEnum.HEAT_RECOVERY),
        selected:  deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.HEAT_RECOVERY,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Estrazione',
        iconData: Icons.arrow_back,
        onTap: () => _changePicoMode(PicoStateEnum.EXTRACTION),
        selected: deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.EXTRACTION,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Immissione',
        iconData: Icons.arrow_right_alt,
        onTap: () => _changePicoMode(PicoStateEnum.IMMISSION),
        selected: deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.IMMISSION,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá umiditá',
        iconData: Icons.heat_pump_sharp,
        onTap: () async {

          final PicoStateEnum? selectedPicoState = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SpecificPicoModeSelectableDialog(
                internalSpecificPicoModeSelectableModelList: [
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_right_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_MODE_RECOVERY,
                    text: 'Recupero',
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_MODE_EXTRACTION,
                    text: 'Estrazione',
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_MODE_EXTRACTION,
                  ),
                ],
              );
            },
          );

          if (selectedPicoState != null) {
            _changePicoMode(selectedPicoState);
          }

        },
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.HUMIDITY_MODE_RECOVERY ||
            currentPicoState == PicoStateEnum.HUMIDITY_MODE_EXTRACTION,
      ),
      InternalGridIconLabelCtaModel(
        text: 'ON / OFF',
        iconData: Icons.settings_remote,
        isOnOffCta: true,
        onTap: () => _executeOnOffCommand(),
        selected: deviceStatus.isDeviceOn,
        borderColor: deviceStatus.isDeviceOn
            ? Colors.green
            : Colors.red,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá CO2 / Umiditiá',
        iconData: Icons.heat_pump_rounded,
        onTap: () async {

          final PicoStateEnum? selectedPicoState = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SpecificPicoModeSelectableDialog(
                internalSpecificPicoModeSelectableModelList: [
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_right_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY,
                    text: 'Recupero',
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION,
                    text: 'Estrazione',
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION,
                  ),
                ],
              );
            },
          );

          if (selectedPicoState != null) {
            _changePicoMode(selectedPicoState);
          }

        },
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION ||
            currentPicoState == PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Comfort',
        iconData: Icons.person,
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.COMFORT_WINTER ||
            currentPicoState == PicoStateEnum.COMFORT_SUMMER,
        onTap: () async {

          final PicoStateEnum? selectedPicoState = await showDialog(
            context:
            context, builder: (BuildContext context) {
              return SpecificPicoModeSelectableDialog(
                internalSpecificPicoModeSelectableModelList: [
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.COMFORT_WINTER,
                    text: 'Inverno',
                    selected: currentPicoState == PicoStateEnum.COMFORT_WINTER,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_right_outlined,
                    picoStateEnum: PicoStateEnum.COMFORT_SUMMER,
                    text: 'Estate',
                    selected: currentPicoState == PicoStateEnum.COMFORT_SUMMER,
                  ),
                ],
              );
            },
          );

          if (selectedPicoState != null) {
            _changePicoMode(selectedPicoState);
          }

        },
      ),
      InternalGridIconLabelCtaModel(
        text: 'Ventilazione naturale',
        iconData: Icons.forest,
        onTap: () => _changePicoMode(PicoStateEnum.NATURAL_VENTILATION),
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.NATURAL_VENTILATION,
      ),
      InternalGridIconLabelCtaModel(
        text: 'Modalitá CO2',
        iconData: Icons.co2,
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.CO2_MODE_RECOVERY ||
            currentPicoState == PicoStateEnum.CO2_MODE_EXTRACTION,
        onTap: () async {

          final PicoStateEnum? selectedPicoState = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SpecificPicoModeSelectableDialog(
                internalSpecificPicoModeSelectableModelList: [
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.CO2_MODE_RECOVERY,
                    text: 'Recupero',
                    selected: currentPicoState == PicoStateEnum.CO2_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_right_outlined,
                    picoStateEnum: PicoStateEnum.CO2_MODE_EXTRACTION,
                    text: 'Estrazione',
                    selected: currentPicoState == PicoStateEnum.EXTRACTION,
                  ),
                ],
              );
            },
          );

          if (selectedPicoState != null) {
            _changePicoMode(selectedPicoState);
          }

        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopPolling();
            context.go(PlantsListPage.route);
          },
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
            style: const TextStyle(
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
                return GestureDetector(
                  onTapUp: (TapUpDetails _) {
                    if (!deviceStatus.isDeviceOn && !item.isOnOffCta) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('VMC é SPENTO, accendilo prima di cambiare modalitá'),
                        ),
                      );
                      return;
                    }
                  },
                  child: GridIconLabelCtaItem(
                    internalGridIconLabelCtaModel: item,
                    isDeviceOn: item.isOnOffCta || deviceStatus.isDeviceOn,
                  ),
                );
              }).toList(),
            ),
          ),

        ],
      ),
    );
  }
}