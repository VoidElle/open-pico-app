import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/use_cases/login_use_case.dart';
import '../providers/pages/auth_page_providers.dart';

class AuthPage extends ConsumerStatefulWidget {

  const AuthPage({super.key});

  static const String route = '/';

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(context),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the title
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Accedi al tuo account',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  // Widget to build the form
  Widget _buildForm() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Form(
          key: ref.watch(authPageFormKeyProvider),
          child: Column(
            children: [

              // Username form field
              TextFormField(
                controller: ref.watch(authPageEmailControllerProvider),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Inserisci il tuo username',
                ),
              ),

              // Password form field
              TextFormField(
                controller: ref.watch(authPagePasswordControllerProvider),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Inserisci la tua password',
                ),
                obscureText: true,
              ),

              // Submit button
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(loginUseCaseProvider).execute(
                      context: context,
                    );
                  },
                  child: const Text('Submit'),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}
