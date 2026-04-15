import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/models/props/polaris_status_page_props.dart';
import 'package:open_pico_app/models/responses/zona_model.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/use_cases/utils/get_device_pin_usecase.dart';

import '../models/responses/device_status.dart';
import '../providers/global/global_providers.dart';
import '../use_cases/network/core/network_handler.dart';
import '../utils/constants/headers_constants.dart';
import '../utils/constants/network_constants.dart';
import 'package:open_pico_app/providers/global/aes_crypt_provider.dart';

class PolarisStatusPage extends ConsumerStatefulWidget {
  const PolarisStatusPage({
    required this.polarisStatusPageProps,
    super.key,
  });

  final PolarisStatusPageProps polarisStatusPageProps;

  static const String route = '/polaris-status';

  @override
  ConsumerState<PolarisStatusPage> createState() => _PolarisStatusPageState();
}

class _PolarisStatusPageState extends ConsumerState<PolarisStatusPage> {
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isExecutingStatusUpdate = false;
  bool _isExecutingApiCall = false;

  late DeviceStatus deviceStatus;
  late List<ZonaModel> zones;
  String? devicePin;

  /// Show raw debug data toggle
  bool _showDebug = false;
  dynamic _rawGetTwResponse;

  @override
  void initState() {
    super.initState();
    deviceStatus = widget.polarisStatusPageProps.deviceStatus;
    zones = widget.polarisStatusPageProps.zones;
    _rawGetTwResponse = widget.polarisStatusPageProps.rawGetTwResponse;
    _initializePolling();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  Future<void> _initializePolling() async {
    try {
      final String deviceSerial = widget.polarisStatusPageProps.responseDeviceModel.serial;
      devicePin = await ref
          .read(getGetDevicePinUsecaseProvider)
          .execute(deviceSerial: deviceSerial);
      _startPolling();
    } catch (e) {
      debugPrint('[PolarisStatusPage] Error initializing polling: $e');
    }
  }

  void _startPolling() {
    if (_isPolling || devicePin == null) return;
    _isPolling = true;
    debugPrint('[PolarisStatusPage] Started polling');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isExecutingStatusUpdate) return;
      await _updateStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  Future<void> _updateStatus() async {
    if (!mounted || devicePin == null) return;
    _isExecutingStatusUpdate = true;

    try {
      final String serial = widget.polarisStatusPageProps.responseDeviceModel.serial;
      final String pin = devicePin!;

      final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';
      final String? currentEmail = ref.read(globalUserEmailProvider);
      final String authorization = NetworkConstants.retrieveApiKey(currentEmail);
      final Dio dio = ref.read(networkHandlerProvider).dio;

      // Fetch GetHome for basic device status (on/off, name)
      final Response<dynamic> homeResponse = await dio.get(
        '/api/v1/GetHome',
        queryParameters: {'cuSerial': serial, 'PIN': pin},
        options: Options(
          headers: {
            ...HeadersConstants.commonHeaders,
            'Token': newToken,
            'Authorization': authorization,
          },
        ),
      );

      // Fetch GetCUState for zone data (separate endpoint, needs fresh token)
      final String newToken2 = ref.read(aesCryptProvider).retrieveNewToken() ?? '';
      final Response<dynamic> stateResponse = await dio.get(
        '/api/v1/GetCUState',
        queryParameters: {'cuSerial': serial, 'PIN': pin},
        options: Options(
          headers: {
            ...HeadersConstants.commonHeaders,
            'Token': newToken2,
            'Authorization': authorization,
          },
        ),
      );

      if (mounted) {
        setState(() {
          // Update device status from GetHome
          final List<dynamic> responseData = homeResponse.data is List
              ? homeResponse.data as List<dynamic>
              : jsonDecode(homeResponse.data as String) as List<dynamic>;
          if (responseData.isNotEmpty) {
            final Map<String, dynamic> cuData = responseData[0] as Map<String, dynamic>;
            final bool isOff = cuData['IsOFF'] == true;
            final bool isCooling = cuData['IsCooling'] == true;
            final int operatingModeCooling = cuData['OperatingModeCooling'] ?? 0;
            deviceStatus = deviceStatus.copyWith(
              onOff: isOff ? 0 : 1,
              name: cuData['Name'] ?? deviceStatus.name,
              mod: isCooling ? operatingModeCooling : 0,
              speed: cuData['FInv'] ?? deviceStatus.speed,
              spdRow: cuData['FEst'] ?? deviceStatus.spdRow,
            );
          }

          // Update zones from GetCUState
          _parseZonesFromStateResponse(stateResponse.data);
        });
      }
    } catch (e) {
      debugPrint('[PolarisStatusPage] Error updating status: $e');
    } finally {
      _isExecutingStatusUpdate = false;
    }
  }

  /// Parses zone data from GetCUState response.
  /// GetCUState may return a direct JSON object, a ResCode/ResDescr wrapper, or an array.
  void _parseZonesFromStateResponse(dynamic responseData) {
    try {
      dynamic parsedData = responseData;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }

      Map<String, dynamic>? cuData;

      if (parsedData is Map<String, dynamic>) {
        if (parsedData.containsKey('ResCode') && parsedData.containsKey('ResDescr')) {
          final dynamic resDescr = parsedData['ResDescr'];
          if (resDescr is String) {
            final decoded = jsonDecode(resDescr);
            if (decoded is Map<String, dynamic>) {
              cuData = decoded;
            } else if (decoded is List && decoded.isNotEmpty) {
              cuData = decoded[0] as Map<String, dynamic>;
            }
          } else if (resDescr is Map<String, dynamic>) {
            cuData = resDescr;
          }
        } else {
          cuData = parsedData;
        }
      } else if (parsedData is List && parsedData.isNotEmpty) {
        cuData = parsedData[0] as Map<String, dynamic>;
      }

      if (cuData != null) {
        final dynamic zonesData = cuData['Zones'];
        if (zonesData is List) {
          zones = zonesData
              .whereType<Map<String, dynamic>>()
              .map((z) => ZonaModel.fromJson(z))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[PolarisStatusPage] Error parsing zones from GetCUState: $e');
    }
  }

  /// Send zone update to the API
  /// Updates zone isOff state and/or setTemp
  Future<void> _sendZoneUpdate(
    ZonaModel zone, {
    bool? newIsOff,
    double? newSetTemp,
  }) async {
    if (devicePin == null) {
      _showSnackBar('Device PIN not available');
      return;
    }

    if (_isExecutingApiCall) {
      _showSnackBar('API call already in progress');
      return;
    }

    _isExecutingApiCall = true;

    try {
      final String serial = widget.polarisStatusPageProps.responseDeviceModel.serial;
      final String pin = devicePin!;
      final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';
      final String? currentEmail = ref.read(globalUserEmailProvider);
      final String authorization = NetworkConstants.retrieveApiKey(currentEmail);
      final Dio dio = ref.read(networkHandlerProvider).dio;

      // Build the command JSON using the snake_case format that the original
      // Android app sends via Zona.update_ZONA_Command().
      // IMPORTANT: The C# server deserializes is_off and is_crono as Int32,
      // so we must send 0/1 integers, NOT true/false booleans.
      final int setTempInt = ((newSetTemp ?? zone.setTemp ?? 20.0) * 10).round();
      final bool effectiveIsOff = newIsOff ?? zone.isOff;

      final Map<String, dynamic> cmdData = {
        'c': 'upd_zona',
        'id_zona': zone.zoneId ?? 0,
        'name': zone.name,
        'is_off': effectiveIsOff ? 1 : 0,
        't_set': setTempInt.toString(),
        'is_crono': zone.isCronoMode ? 1 : 0,
      };

      // Add fan_set / shu_set if available (mirroring Android logic)
      if (zone.fancoilSet != null && zone.fancoilSet != -1) {
        final int fanVal = zone.fancoilSet == 7 ? 16 : zone.fancoilSet!;
        cmdData['fan_set'] = fanVal;
        cmdData['shu_set'] = fanVal;
      } else if (zone.serrandaSet != null && zone.serrandaSet != -1) {
        final int shuVal = zone.serrandaSet == 7 ? 16 : zone.serrandaSet!;
        cmdData['shu_set'] = shuVal;
        cmdData['fan_set'] = shuVal;
      }

      // The Android app adds "pin" to the command before sending to the server
      cmdData['pin'] = pin;

      final Map<String, dynamic> updateBody = {
        'Cmd': jsonEncode(cmdData),
        'Name': deviceStatus.name,
        'Pin': pin,
        'Serial': serial,
        'ZoneId': zone.zoneId ?? 0,
      };

      debugPrint('[ZONE_UPDATE] Body: $updateBody');
      debugPrint('[ZONE_UPDATE] Cmd: ${updateBody['Cmd']}');

      final Response<dynamic> response = await dio.post(
        '/api/v1/UpdateZonaData',
        queryParameters: {'cuSerial': serial, 'PIN': pin},
        data: updateBody,
        options: Options(
          headers: {
            ...HeadersConstants.commonHeaders,
            'Token': newToken,
            'Authorization': authorization,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      );

      debugPrint('[PolarisStatusPage] Zone update response: ${response.statusCode}');
      _showSnackBar('Zone updated successfully');

      // Refresh status after update
      await _updateStatus();
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('[ZONE_UPDATE] FAILED ${e.response?.statusCode}: ${e.response?.data}');
      } else {
        debugPrint('[ZONE_UPDATE] Error: $e');
      }
      _showSnackBar('Error updating zone');
    } finally {
      _isExecutingApiCall = false;
    }
  }

  /// Send CU (device) update to the API.
  /// Supports on/off toggle AND cooling operating mode changes.
  /// Operating mode values: 0 = heating/off, 1 = Raffrescamento, 2 = Deumidificazione, 3 = Ventilazione
  Future<void> _sendCuUpdate({
    bool? isOff,
    bool? isCooling,
    int? operatingMode,
  }) async {
    if (devicePin == null) {
      _showSnackBar('Device PIN not available');
      return;
    }

    if (_isExecutingApiCall) {
      _showSnackBar('API call already in progress');
      return;
    }

    _isExecutingApiCall = true;

    try {
      final String serial = widget.polarisStatusPageProps.responseDeviceModel.serial;
      final String pin = devicePin!;
      final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';
      final String? currentEmail = ref.read(globalUserEmailProvider);
      final String authorization = NetworkConstants.retrieveApiKey(currentEmail);
      final Dio dio = ref.read(networkHandlerProvider).dio;

      // Build command matching Android ControlUnit.update_CU_command():
      //   {"c":"upd_cu","pin":"...","is_off":0/1,"is_cool":0/1,
      //    "cool_mod":0-3,"t_can":NNN,"f_inv":N,"f_est":N}
      final bool effectiveIsOff = isOff ?? !deviceStatus.isDeviceOn;
      final bool effectiveIsCooling = isCooling ?? (deviceStatus.mod > 0);
      final int effectiveOperatingMode = operatingMode ?? deviceStatus.mod;

      final Map<String, dynamic> commandJson = {
        'c': 'upd_cu',
        'pin': pin,
        'is_off': effectiveIsOff ? 1 : 0,
        'is_cool': effectiveIsCooling ? 1 : 0,
        'cool_mod': effectiveOperatingMode,
        't_can': 0,
        'f_inv': deviceStatus.speed,
        'f_est': deviceStatus.spdRow,
      };
      final Map<String, dynamic> updateBody = {
        'Cmd': jsonEncode(commandJson),
        'Name': deviceStatus.name,
        'Pin': pin,
        'Serial': serial,
      };

      debugPrint('[PolarisStatusPage] Sending CU update: $updateBody');

      final Response<dynamic> response = await dio.post(
        '/api/v1/UpdateCUData',
        queryParameters: {'cuSerial': serial, 'PIN': pin},
        data: updateBody,
        options: Options(
          headers: {
            ...HeadersConstants.commonHeaders,
            'Token': newToken,
            'Authorization': authorization,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      );

      debugPrint('[PolarisStatusPage] CU update response: ${response.statusCode}');
      _showSnackBar('Device updated successfully');

      // Refresh status after update
      await _updateStatus();
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('[CU_UPDATE] FAILED ${e.response?.statusCode}: ${e.response?.data}');
      } else {
        debugPrint('[CU_UPDATE] Error: $e');
      }
      _showSnackBar('Error updating device');
    } finally {
      _isExecutingApiCall = false;
    }
  }

  /// Show the cooling operating mode popup (Raffrescamento / Deumidificazione / Ventilazione)
  void _showCoolingModeDialog() {
    final int currentMode = deviceStatus.mod;
    showDialog<int>(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          title: const Text('MOD. CONDIZIONAMENTO'),
          children: [
            _coolingModeOption(ctx, 'RAFFRESCAMENTO', Icons.ac_unit, 1, currentMode),
            const Divider(height: 1),
            _coolingModeOption(ctx, 'DEUMIDIFICAZIONE', Icons.water_drop_outlined, 2, currentMode),
            const Divider(height: 1),
            _coolingModeOption(ctx, 'VENTILAZIONE', Icons.air, 3, currentMode),
          ],
        );
      },
    ).then((selectedMode) {
      if (selectedMode != null) {
        _sendCuUpdate(
          isOff: false,
          isCooling: true,
          operatingMode: selectedMode,
        );
      }
    });
  }

  Widget _coolingModeOption(BuildContext ctx, String label, IconData icon, int mode, int currentMode) {
    final bool isSelected = mode == currentMode;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, mode),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600], size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: Colors.blue, size: 20),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopPolling();
            context.go(PlantsListPage.route);
          },
        ),
        title: Text(deviceStatus.name),
        actions: [
          // Debug toggle button
          IconButton(
            icon: Icon(_showDebug ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () => setState(() => _showDebug = !_showDebug),
            tooltip: 'Toggle debug view',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Device status header
            _buildDeviceHeader(),
            const SizedBox(height: 16),

            // Zone list or empty state
            if (zones.isNotEmpty) ...[
              Text(
                'Zone',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...zones.map((zone) => _buildZoneCard(zone)),
            ] else ...[
              _buildNoZonesCard(),
            ],

            // Debug section
            if (_showDebug) ...[
              const Divider(height: 32),
              _buildDebugSection(),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns a human-readable label for the current cooling operating mode.
  String _coolingModeLabel(int mode) {
    switch (mode) {
      case 1: return 'Raffrescamento';
      case 2: return 'Deumidificazione';
      case 3: return 'Ventilazione';
      default: return 'Riscaldamento';
    }
  }

  /// Returns an icon for the current cooling operating mode.
  IconData _coolingModeIcon(int mode) {
    switch (mode) {
      case 1: return Icons.ac_unit;
      case 2: return Icons.water_drop_outlined;
      case 3: return Icons.air;
      default: return Icons.wb_sunny;
    }
  }

  Widget _buildDeviceHeader() {
    final bool isOn = deviceStatus.isDeviceOn;
    final int coolingMode = deviceStatus.mod; // 0=heating, 1=raff, 2=deum, 3=vent
    final bool isCooling = coolingMode > 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: device info + power switch
            Row(
              children: [
                Icon(
                  isOn ? Icons.power : Icons.power_off,
                  size: 40,
                  color: isOn ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceStatus.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOn ? 'Acceso' : 'Spento',
                        style: TextStyle(
                          fontSize: 16,
                          color: isOn ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (deviceStatus.fwVer.isNotEmpty)
                        Text(
                          'FW: ${deviceStatus.fwVer}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                // Power toggle switch
                Switch(
                  value: isOn,
                  onChanged: _isExecutingApiCall
                      ? null
                      : (value) {
                          _sendCuUpdate(isOff: !value);
                        },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row: mode buttons (cooling / power / heating) — like original app
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cooling mode button (snowflake)
                _modeButton(
                  icon: Icons.ac_unit,
                  label: 'Freddo',
                  isActive: isCooling,
                  activeColor: Colors.blue,
                  onTap: _isExecutingApiCall ? null : () => _showCoolingModeDialog(),
                ),
                // Power/mode indicator
                Column(
                  children: [
                    Icon(
                      _coolingModeIcon(coolingMode),
                      size: 28,
                      color: isCooling ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _coolingModeLabel(coolingMode),
                      style: TextStyle(
                        fontSize: 11,
                        color: isCooling ? Colors.blue : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Heating mode button (sun)
                _modeButton(
                  icon: Icons.wb_sunny,
                  label: 'Caldo',
                  isActive: !isCooling,
                  activeColor: Colors.orange,
                  onTap: _isExecutingApiCall
                      ? null
                      : () {
                          _sendCuUpdate(
                            isOff: false,
                            isCooling: false,
                            operatingMode: 0,
                          );
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.grey, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(ZonaModel zone) {
    final bool zoneOn = zone.isOn;
    final double currentSetTemp = zone.setTemp ?? 20.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Zone icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: zoneOn ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.meeting_room,
                    color: zoneOn ? Colors.blue : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Zone name and state
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (zone.isCronoMode)
                        Text(
                          'Crono',
                          style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                        ),
                      if (zone.hasError)
                        Text(
                          'Errore (${zone.numError})',
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                ),
                // Temperature display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (zone.currentTemp != null)
                      Text(
                        '${zone.currentTemp!.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (zone.humidity != null)
                      Text(
                        'Umidità: ${zone.humidity!.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                // On/Off indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: zoneOn ? Colors.green : Colors.red.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Zone controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Zone on/off toggle
                Row(
                  children: [
                    const Text(
                      'Zone:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: zoneOn,
                      onChanged: _isExecutingApiCall
                          ? null
                          : (value) {
                              _sendZoneUpdate(zone, newIsOff: !value);
                            },
                    ),
                  ],
                ),
                // Temperature adjustment controls
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _isExecutingApiCall
                          ? null
                          : () {
                              final newTemp = (currentSetTemp - 0.5).clamp(10.0, 30.0);
                              _sendZoneUpdate(zone, newSetTemp: newTemp);
                            },
                      tooltip: 'Decrease temperature',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${currentSetTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _isExecutingApiCall
                          ? null
                          : () {
                              final newTemp = (currentSetTemp + 0.5).clamp(10.0, 30.0);
                              _sendZoneUpdate(zone, newSetTemp: newTemp);
                            },
                      tooltip: 'Increase temperature',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoZonesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              'Nessuna zona trovata',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nessun endpoint zone trovato.\n'
              'Premi il pulsante debug (icona insetto in alto) per vedere le risposte degli endpoint provati.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DEBUG INFO', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.orange)),
        const SizedBox(height: 8),

        // Device Status raw
        _buildDebugCard('DeviceStatus JSON', const JsonEncoder.withIndent('  ').convert(deviceStatus.toJson())),
        const SizedBox(height: 8),

        // Zone discovery raw response
        _buildDebugCard(
          'Zone Discovery Raw Response',
          _rawGetTwResponse != null
              ? _formatDebugData(_rawGetTwResponse)
              : 'No zone discovery response',
        ),
        const SizedBox(height: 8),

        // Parsed zones
        _buildDebugCard(
          'Parsed Zones (${zones.length})',
          zones.isEmpty
              ? 'No zones parsed'
              : zones.map((z) => '${z.toString()}\nRaw: ${const JsonEncoder.withIndent("  ").convert(z.rawData)}').join('\n\n'),
        ),
      ],
    );
  }

  String _formatDebugData(dynamic data) {
    try {
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  Widget _buildDebugCard(String title, String content) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                  onPressed: () {
                    // Copy to clipboard
                    debugPrint('======= $title =======');
                    debugPrint(content);
                    debugPrint('======================');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title logged to console')),
                    );
                  },
                  tooltip: 'Log to console',
                ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              content,
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
