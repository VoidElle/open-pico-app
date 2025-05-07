import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {

  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // Key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Inserisci il tuo username',
            ),
          ),

          // Password form field
          TextFormField(
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
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
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
