import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/pages/auth_page.dart';
import 'package:open_pico_app/pages/devices_list_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: const OpenPico(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: AuthPage.route,
      builder: (BuildContext context, GoRouterState state) => AuthPage(),
    ),
    GoRoute(
      path: DevicesListPage.route,
      builder: (BuildContext context, GoRouterState state) => DevicesListPage(),
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
