import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/utils/aes_crypt.dart';
import 'package:open_pico_app/utils/constants/network_constants.dart';

import '../providers/global/global_providers.dart';
import '../providers/global/global_rest_client_providers.dart';

class DevicesListPage extends ConsumerStatefulWidget {

  const DevicesListPage({super.key});

  static const String route = '/devices-list';

  @override
  ConsumerState<DevicesListPage> createState() => _DevicesListPageState();
}

class _DevicesListPageState extends ConsumerState<DevicesListPage> {

  @override
  void initState() {

    final String newToken = ref.read(aesCryptProvider).retrieveNewToken() ?? '';

    final String? currentEmail = ref.read(globalUserEmailProvider);
    final String authorization = NetworkConstants.retrieveApiKey(currentEmail);

    ref.read(picoRestClientProvider).getPlants(newToken, authorization);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices List'),
      ),
      body: const Center(
        child: Text('Devices List Page'),
      ),
    );
  }
}
