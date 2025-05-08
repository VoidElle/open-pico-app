import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/aes_crypt.dart';

class AuthPage extends ConsumerStatefulWidget {

  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {

  // Key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // Username form field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Inserisci il tuo username',
            ),
          ),

          // Password form field
          TextFormField(
            controller: _passwordController,
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
                if (_formKey.currentState!.validate()) {

                  print('Username: ${_emailController.text}');
                  print('Clear Password: ${_passwordController.text}');
                  print('DESIDERED OUTPUT -> J9t31KUVnRWaCKc1NplO5A==');

                  // Encrypt the password using the provider
                  final String encryptedPassword = ref.read(aesCryptProvider).encryptText(_passwordController.text);
                  print('REAL OUTPUT ->  ${encryptedPassword}');

                }
              },
              child: const Text('Submit'),
            ),
          ),

        ],
      ),
    );
  }
}
