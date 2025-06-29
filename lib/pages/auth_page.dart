import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/repositories/secure_storage_repository.dart';
import 'package:open_pico_app/use_cases/secure_storage/secure_storage_write_read_login_data_usecase.dart';

import '../use_cases/network/executor/login_use_case.dart';
import '../providers/pages/auth_page_providers.dart';

class AuthPage extends ConsumerStatefulWidget {

  const AuthPage({super.key});

  static const String route = '/';

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {

  // State variable to toggle password visibility
  bool _showPassword = false;

  // State variable to determine if the credentials should be saved
  bool _savePassword = false;

  @override
  void initState() {

    // Instance the SecureStorageWriteReadLoginDataUseCase
    final SecureStorageWriteReadLoginDataUseCase secureStorageWriteReadLoginDataUseCase = SecureStorageWriteReadLoginDataUseCase(SecureStorageRepository.instance);

    // Retrieve saved login data from secure storage
    secureStorageWriteReadLoginDataUseCase.readData().then((Map<String, dynamic> data) {

      // If the data is empty, do nothing
      if (data.isEmpty) {
        return;
      }

      // Set the email and password fields with the retrieved data
      ref.read(authPageEmailControllerProvider).text = data['email'];
      ref.read(authPagePasswordControllerProvider).text = data['password'];

      // Execute the login flow
      ref.read(loginUseCaseProvider).execute(
        context: context,
        savePassword: true,
      );

    });

    super.initState();
  }

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
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Inserisci la tua password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
                obscureText: !_showPassword,
              ),

              Row(
                children: [
                  Checkbox(
                    value: _savePassword,
                    onChanged: (bool? value) {
                      setState(() {
                        _savePassword = value ?? false;
                      });
                    },
                  ),
                  const Text('Salva password'),
                ],
              ),

              // Submit button
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(loginUseCaseProvider).execute(
                      context: context,
                      savePassword: _savePassword
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
