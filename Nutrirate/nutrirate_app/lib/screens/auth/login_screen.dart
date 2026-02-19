import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinput/pinput.dart'; // Import this for the modern UI
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLogin = true;
  bool _needsVerification = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Professional Theme for the OTP cells
  final defaultPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
  );

  // --- Logic remains similar but UI is overhauled ---

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty && !_needsVerification) return;

    setState(() => _isLoading = true);

    try {
      if (_needsVerification) {
        await _verifyOtp(email);
      } else if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        _navigateToHome();
      } else {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        setState(() => _needsVerification = true);
        _showSnack("Check your inbox for the code!", Colors.blue);
      }
    } on AuthException catch (e) {
      _showSnack(e.message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp(String email) async {
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: _otpController.text,
        email: email,
      );
      _navigateToHome();
    } catch (e) {
      _showSnack("Invalid or Expired Code", Colors.red);
    }
  }

  void _navigateToHome() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.health_and_safety_rounded, size: 70, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                _needsVerification ? "Verify Your Email" : (_isLogin ? "Welcome Back" : "Create Account"),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              if (!_needsVerification) ...[
                // --- Email & Password UI ---
                _buildField(_emailController, "Email", Icons.email_outlined, false),
                const SizedBox(height: 16),
                _buildPasswordField(),
              ] else ...[
                // --- MODERN OTP SPACE ---
                const Text("Enter the 6-digit code sent to your email", textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(color: Colors.green[50]),
                  ),
                  onCompleted: (pin) => _submit(),
                ),
                const SizedBox(height: 30),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_needsVerification ? "Verify Account" : (_isLogin ? "Login" : "Register")),
                ),
              ),

              if (!_needsVerification)
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? "Create an account" : "Have an account? Login", style: const TextStyle(color: Colors.green)),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _needsVerification = false),
                  child: const Text("Use a different email", style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, bool obscure) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelText: "Password",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}