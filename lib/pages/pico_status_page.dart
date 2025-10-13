import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/dialogs/specific_pico_mode_selectable_dialog.dart';
import 'package:open_pico_app/models/internal/internal_grid_icon_label_cta_model.dart';
import 'package:open_pico_app/models/responses/device_status.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/providers/global/global_providers.dart';
import 'package:open_pico_app/use_cases/status/retrieve_device_status_usecase.dart';
import 'package:open_pico_app/use_cases/utils/get_device_pin_usecase.dart';
import 'package:open_pico_app/utils/command_utils.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/internal/internal_specific_pico_mode_selectable_model.dart';
import '../models/props/pico_status_page_props.dart';
import '../models/responses/response_device_model.dart';
import '../use_cases/pico/pico_execute_command_usecase.dart';
import '../utils/constants/supported_modes_constants.dart';
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

  // The fan speed of the slider
  late int _fanSpeed;

  // Add debounce timer for fan speed
  Timer? _fanSpeedDebounceTimer;
  static const Duration _fanSpeedDebounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {

    super.initState();

    deviceStatus = widget.picoStatusPageProps.deviceStatus;
    _fanSpeed = deviceStatus.spdRich;

    _initializePolling();
  }

  @override
  void dispose() {
    _stopPolling();
    _fanSpeedDebounceTimer?.cancel();
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
        setState(() {
          deviceStatus = updatedDeviceStatus;
          _fanSpeed = updatedDeviceStatus.spdRich;
        });
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

      // Retrieve the global idp counter
      final int idpCounter = await ref
          .read(globalIdpCounterRepositoryProvider);

      // Retrieve the change mode command
      final String command = CommandUtils
          .getCmdFromPicoState(idpCounter, picoStateEnum, devicePin);

      // Execute the command
      await ref
          .read(getPicoExecuteCommandUsecaseProvider)
          .execute(
            deviceName: deviceStatus.name,
            deviceSerial: responseDeviceModel.serial,
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

      // Retrieve the global idp counter
      final int idpCounter = await ref
          .read(globalIdpCounterRepositoryProvider);

      // Retrieve the command ON or OFF
      final String command = CommandUtils
          .getOnOffCmd(idpCounter, !deviceStatus.isDeviceOn, devicePin);

      // Execute the command
      await ref
          .read(getPicoExecuteCommandUsecaseProvider)
          .execute(
            deviceName: deviceStatus.name,
            deviceSerial: responseDeviceModel.serial,
            command: command,
          );

    } catch (e) {
      debugPrint('Error executing ON/OFF command: $e');
    }
  }

  Future<void> _changeFanSpeed(int newFanSpeed) async {
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

      // Retrieve the global idp counter
      final int idpCounter = await ref
          .read(globalIdpCounterRepositoryProvider);

      // Retrieve the command to change the fan speed
      final String command = CommandUtils
          .getSetSpeedCmd(idpCounter, newFanSpeed, devicePin);

      // Execute the command
      await ref
          .read(getPicoExecuteCommandUsecaseProvider)
          .execute(
            deviceName: deviceStatus.name,
            deviceSerial: responseDeviceModel.serial,
            command: command,
          );

    } catch (e) {
      debugPrint('Error changing fan speed: $e');
    }
  }

  // Debounced fan speed change handler
  void _onFanSpeedChanged(int newFanSpeed) {
    // Cancel previous timer if it exists
    _fanSpeedDebounceTimer?.cancel();

    // Optimistic update of the UI
    setState(() {
      _fanSpeed = newFanSpeed;
    });

    // Set up a new timer
    _fanSpeedDebounceTimer = Timer(_fanSpeedDebounceDuration, () {
      /// This will only execute after the user stops sliding for [_fanSpeedDebounceDuration]ms
      _changeFanSpeed(_fanSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {

    final int currentModToParse = deviceStatus.mod;
    final PicoStateEnum currentPicoState = PicoStateEnumUtils.getPicoStateEnumFromMod(currentModToParse);

    final List<InternalGridIconLabelCtaModel> items = <InternalGridIconLabelCtaModel>[
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.heat_recovery_label"),
        iconData: Icons.hot_tub,
        onTap: () => _changePicoMode(PicoStateEnum.HEAT_RECOVERY),
        selected:  deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.HEAT_RECOVERY,
      ),
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.extraction_label"),
        iconData: Icons.arrow_back,
        onTap: () => _changePicoMode(PicoStateEnum.EXTRACTION),
        selected: deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.EXTRACTION,
      ),
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.immission_label"),
        iconData: Icons.arrow_right_alt,
        onTap: () => _changePicoMode(PicoStateEnum.IMMISSION),
        selected: deviceStatus.isDeviceOn && currentPicoState == PicoStateEnum.IMMISSION,
      ),
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.humidity_mode_label"),
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
                    text: tr("global.recovery_label"),
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_MODE_EXTRACTION,
                    text: tr("global.extraction_label"),
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
        text: tr("plant_detail.on_off_label"),
        iconData: Icons.settings_remote,
        isOnOffCta: true,
        onTap: () => _executeOnOffCommand(),
        selected: deviceStatus.isDeviceOn,
        borderColor: deviceStatus.isDeviceOn
            ? Colors.green
            : Colors.red,
      ),
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.co2_humidity_mode_label"),
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
                    text: tr("global.recovery_label"),
                    selected: currentPicoState == PicoStateEnum.HUMIDITY_CO2_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_left_outlined,
                    picoStateEnum: PicoStateEnum.HUMIDITY_CO2_MODE_EXTRACTION,
                    text: tr("global.extraction_label"),
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
        text: tr("plant_detail.comfort_mode_label"),
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
                    icon: Icons.severe_cold,
                    picoStateEnum: PicoStateEnum.COMFORT_WINTER,
                    text: tr("global.winter_label"),
                    selected: currentPicoState == PicoStateEnum.COMFORT_WINTER,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.local_fire_department_rounded,
                    picoStateEnum: PicoStateEnum.COMFORT_SUMMER,
                    text: tr("global.summer_label"),
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
        text: tr("plant_detail.natural_ventilation_label"),
        iconData: Icons.forest,
        onTap: () => _changePicoMode(PicoStateEnum.NATURAL_VENTILATION),
        selected: deviceStatus.isDeviceOn &&
            currentPicoState == PicoStateEnum.NATURAL_VENTILATION,
      ),
      InternalGridIconLabelCtaModel(
        text: tr("plant_detail.co2_mode"),
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
                    text: tr("global.recovery_label"),
                    selected: currentPicoState == PicoStateEnum.CO2_MODE_RECOVERY,
                  ),
                  InternalSpecificPicoModeSelectableModel(
                    icon: Icons.arrow_circle_right_outlined,
                    picoStateEnum: PicoStateEnum.CO2_MODE_EXTRACTION,
                    text: tr("global.extraction_label"),
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
            tr(
              "plant_detail.on_off_status_placeholder",
              args: [
                deviceStatus.isDeviceOn
                    ? "ON"
                    : "OFF",
              ],
            ),
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
                        SnackBar(
                          content: Text(
                            tr("plant_detail.set_mode_while_off_error"),
                          ),
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

          if (SupportedModesConstants.fanSpeedSupportedPresetModes.contains(currentPicoState))
            _buildFanSpeedWidget(),

        ],
      ),
    );
  }

  Widget _buildFanSpeedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Fan speed",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: _fanSpeed.toDouble(),
          min: 0,
          max: 100,
          onChanged: (double newValue) => _onFanSpeedChanged(newValue.toInt()),
        ),
        Text(
          "${_fanSpeed.toInt()}%",
          style: const TextStyle(
            fontSize: 18,
          ),
        )
      ],
    );
  }

}