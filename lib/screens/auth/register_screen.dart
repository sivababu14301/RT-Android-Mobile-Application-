import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/logo_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rememberKeyController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rememberKeyController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service'), backgroundColor: AppColors.error),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _mobileController.text.trim(),
        _passwordController.text,
        _rememberKeyController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.'), backgroundColor: AppColors.success),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const LogoWidget(size: 60),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.headingAccentGradient.createShader(bounds),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join RT Raymaans Tailors today',
                        style: TextStyle(color: AppColors.gold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  hintText: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                _buildInputField(
                  hintText: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
                    return null;
                  },
                ),
                _buildInputField(
                  hintText: 'Mobile Number',
                  controller: _mobileController,
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Enter valid mobile number' : null,
                ),
                _buildInputField(
                  hintText: 'Password',
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
                _buildInputField(
                  hintText: 'Remember Access Key',
                  controller: _rememberKeyController,
                  icon: Icons.key_outlined,
                  validator: (v) => v!.isEmpty ? 'Remember Access Key is required' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) => setState(() => _acceptTerms = v!),
                        activeColor: AppColors.gold,
                        checkColor: Colors.black,
                        side: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          children: [
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: AppColors.authButtonGradient,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    double paddingBottom = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        validator: validator,
        cursorColor: AppColors.gold,
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
