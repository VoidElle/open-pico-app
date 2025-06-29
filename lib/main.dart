import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/pages/auth_page.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/repositories/secure_storage_repository.dart';
import 'package:open_pico_app/utils/global_singleton.dart';

void main() {

  // Initialize the secure storage repository
  SecureStorageRepository.initialize();

  runApp(
    ProviderScope(
      child: const OpenPico(),
    ),
  );
}

final GoRouter _router = GoRouter(
  navigatorKey: GlobalSingleton.navigatorKey,
  routes: [
    GoRoute(
      path: AuthPage.route,
      builder: (BuildContext context, GoRouterState state) => AuthPage(),
    ),
    GoRoute(
      path: PlantsListPage.route,
      builder: (BuildContext context, GoRouterState state) => PlantsListPage(),
    ),
  ],
);

class OpenPico extends StatelessWidget {

  const OpenPico({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Open Pico',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      // home: const AuthPage(),
    );
  }

}
