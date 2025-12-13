import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import 'package:smartmeter/screens/register_screen.dart';
import '../config/theme.dart';

String? clientId;
String? serverClientId;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  static const String _universityDomain = "@student.uthm.edu.my";

  @override
  void initState() {
    super.initState();
    _setupGoogleSignIn();
  }

  Future<void> _setupGoogleSignIn() async {
    _googleSignIn.authenticationEvents.listen((event) {
      if (mounted) {
        setState(() {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _currentUser = event.user;
            _handleAuthSuccess(event.user);
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            _currentUser = null;
          }
        });
      }
    }).onError((error) {
      _handleAuthError(error);
    });

      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> _handleAuthSuccess(GoogleSignInAccount user) async {
    try {
      final GoogleSignInAuthentication auth = user.authentication;

      final String matricNumber = user.email.split('@').first;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
                initialMatric: matricNumber,
                initialEmail: user.email
            ),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${user.displayName}!")),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = "Auth success processing failed: $e");
    }
  }

  Future<void> _handleGoogleBtnClick() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.authenticate();
    } catch (error) {
      _handleAuthError(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAuthError(Object e) {
    setState(() {
      if (e is GoogleSignInException) {
        _errorMessage = "Error: ${e.code.name}";
      } else {
        _errorMessage = 'Unknown error: $e';
      }
      _isLoading = false;
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    String input = _idCtrl.text.trim();
    String emailToUse = input;

    if (!input.contains('@')) {
      emailToUse = "$input$_universityDomain";
    }

    try {
      await context.read<AuthProvider>().login(emailToUse, _passCtrl.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
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

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                ),

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

              const SizedBox(height: 24),

              const Row(children: <Widget>[
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ]),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleBtnClick,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Sign in with Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}