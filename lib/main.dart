import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/pages/auth_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: const OpenPico(),
    ),
  );
}

class OpenPico extends StatelessWidget {

  const OpenPico({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Pico',
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
      home: const AuthPage(),
    );
  }

}
