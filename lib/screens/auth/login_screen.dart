import 'package:flutter/material.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/screens/auth/register_screen.dart';
import 'package:personal_finance_lite/utils/dialogs.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    showLoadingDialog(context);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_email.text.trim(), _pass.text.trim());
      Navigator.of(context).pop(); // Dismiss loading dialog
      showSuccessDialog(context, 'Login successful!');
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('LOGIN'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen())),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}