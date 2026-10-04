import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/logo_widget.dart';
import 'new_password_screen.dart';

class VerifyAccessScreen extends StatefulWidget {
  final String email;
  const VerifyAccessScreen({super.key, required this.email});

  @override
  State<VerifyAccessScreen> createState() => _VerifyAccessScreenState();
}

class _VerifyAccessScreenState extends State<VerifyAccessScreen> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.verifyRememberAccess(widget.email, _keyController.text.trim());
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(
              email: widget.email,
              rememberKey: _keyController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LogoWidget(size: 60),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.headingAccentGradient.createShader(bounds),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "We'll help you get back into your account",
                      style: TextStyle(color: AppColors.gold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                hintText: 'Password Remember Access Key',
                controller: _keyController,
                icon: Icons.key_outlined,
                validator: (v) => v!.isEmpty ? 'Key is required' : null,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: AppColors.authButtonGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        onPressed: _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                          'VERIFY KEY',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: AppColors.gold,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF111111),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.gold, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.brightGold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.gold, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
