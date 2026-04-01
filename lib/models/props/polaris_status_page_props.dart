import '../responses/device_status.dart';
import '../responses/response_device_model.dart';
import '../responses/zona_model.dart';

/// Props for the Polaris status page.
/// Contains the device status, device model info, and zone data.
class PolarisStatusPageProps {
  final DeviceStatus deviceStatus;
  final ResponseDeviceModel responseDeviceModel;
  final List<ZonaModel> zones;

  /// Raw GetTW response for debugging (will be removed once zone parsing is stable)
  final dynamic rawGetTwResponse;

  const PolarisStatusPageProps({
    required this.deviceStatus,
    required this.responseDeviceModel,
    required this.zones,
    this.rawGetTwResponse,
  });
}
