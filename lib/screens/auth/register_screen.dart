import 'package:flutter/material.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/utils/dialogs.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    showLoadingDialog(context);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .register(_email.text.trim(), _pass.text.trim());
      Navigator.of(context).pop(); // Dismiss loading dialog
      showSuccessDialog(context, 'Registration successful!');
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Password (6+ chars)'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('REGISTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}