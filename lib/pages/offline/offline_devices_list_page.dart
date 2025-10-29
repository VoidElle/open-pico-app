import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/repositories/shared_preferences_repository.dart';

import '../../widgets/offline/add_ip_address_bottom_sheet.dart';

class OfflineDevicesListPage extends StatelessWidget {

  const OfflineDevicesListPage({super.key});

  static const String route = '/offline-devices-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Back button
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.chevron_left,
              size: 32,
            ),
          ),

          Center(
            child: _addDeviceButton(context),
          ),

        ],
      ),
    );
  }

  Widget _addDeviceButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final String? result = await _showAddIpBottomSheet(context);
        if (result != null && result.isNotEmpty) {

          // Save the IP address to shared preferences
          await SharedPreferencesRepository.saveOfflineDeviceIp(result);

        }
      },
      child: DottedBorder(
        options: RectDottedBorderOptions(
          color: Colors.grey,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
        ),
        child: Container(
          width: 140,
          height: 140,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.hvac_outlined,
                color: Colors.grey,
                size: 36,
              ),
              SizedBox(height: 8),
              Text(
                "Add a device",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddIpBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext _) => const AddIpAddressBottomSheet(),
    );
  }

}
