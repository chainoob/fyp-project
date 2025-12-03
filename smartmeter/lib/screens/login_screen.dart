import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import '../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailMatricCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(_emailMatricCtrl.text, _passCtrl.text);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 80, color: AppTheme.navyBlue),
              const SizedBox(height: 24),
              const Text("SmartMeter", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text("Energy Management System", style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 48),
              
              TextField(
                controller: _emailMatricCtrl,
                decoration: const InputDecoration(labelText: "Email or Matric Number", prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 32),
              
              _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _handleLogin, child: const Text("login")),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}