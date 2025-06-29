import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../use_cases/auth/logout_use_case.dart';

class PlantsListAppbar extends ConsumerWidget implements PreferredSizeWidget {

  const PlantsListAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text(
        'Plants list',
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {

            // Logout action is pressed
            if (value == 'logout') {

              // Execute the logout use case
              final LogoutUseCase logoutUseCase = ref.read(getLogoutUseCaseProvider);
              logoutUseCase.execute(context: context);

            }

          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
