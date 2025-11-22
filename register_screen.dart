// lib/screens/register_screen.dart
import 'package:flutter/material.dart';

class RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const RoundedField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _abhaCtl = TextEditingController();
  final _mobileCtl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _abhaCtl.dispose();
    _mobileCtl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF0E9E89);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create your Account',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: teal,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join Aayutrack and begin your health journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            RoundedField(
                              controller: _emailCtl,
                              hint: 'Email ID *',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            RoundedField(
                              controller: _passCtl,
                              hint: 'Password *',
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (v.length < 6) return 'Min 6 chars';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            RoundedField(
                              controller: _abhaCtl,
                              hint: 'ABHA ID *',
                              icon: Icons.badge_outlined,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            RoundedField(
                              controller: _mobileCtl,
                              hint: 'Mobile Number (optional)',
                              icon: Icons.phone,
                              keyboard: TextInputType.phone,
                              validator: (v) {
                                if (v != null &&
                                    v.trim().isNotEmpty &&
                                    v.length < 10) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saving ? null : _register,
                                icon: const Icon(Icons.check),
                                label: Text(
                                  _saving ? 'Registering...' : 'Register',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: teal,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
