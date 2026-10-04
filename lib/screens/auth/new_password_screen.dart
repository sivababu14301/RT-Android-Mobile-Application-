import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/logo_widget.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String rememberKey;
  const NewPasswordScreen({super.key, required this.email, required this.rememberKey});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.resetPassword(widget.email, _passwordController.text, rememberAccess: widget.rememberKey);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful! Please login.'), backgroundColor: AppColors.success),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
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
                        'New Password',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Enter your new secure password",
                      style: TextStyle(color: AppColors.gold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                hintText: 'New Password',
                controller: _passwordController,
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !_showPassword,
                onToggleVisibility: () => setState(() => _showPassword = !_showPassword),
                validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              _buildInputField(
                hintText: 'Confirm Password',
                controller: _confirmPasswordController,
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                obscureText: !_showConfirmPassword,
                onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
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
                        onPressed: _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                          'RESET PASSWORD',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
                        ),
                      ),
                    ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: AppColors.gold,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF111111),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.gold, size: 20),
                  onPressed: onToggleVisibility,
                )
              : null,
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
