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
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  static const String _universityDomain = "@student.uthm.edu.my";

  void _handleLogin() async {
    setState(() => _isLoading = true);

    //Check if it's an ID or Email
    String input = _idCtrl.text.trim();
    String emailToUse = input;

    if (!input.contains('@')) {
      emailToUse = "$input$_universityDomain";
    }

    try {
      await context.read<AuthProvider>().login(emailToUse, _passCtrl.text);
    } catch (e) {
      if (mounted) {
        // Show clearer error message
        String message = "Login failed";
        if (e.toString().contains("user-not-found")) {
          message = "ID/Email not found. Did you register?";
        } else if (e.toString().contains("wrong-password")) {
          message = "Incorrect password";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
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

              // Updated Input Decoration
              TextField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                    labelText: "Matric Number or Email",
                    prefixIcon: Icon(Icons.badge_outlined)
                ),
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
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text("SECURE LOGIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}