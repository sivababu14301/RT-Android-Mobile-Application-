import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../widgets/logo_widget.dart';
import '../customer_main_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    try {
      final message = await userProvider.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.success),
        );
        
        final user = userProvider.user;
        if (user != null) {
          final bool isAdmin = user.role == 'admin' || user.email.trim().toLowerCase() == 'admin@raymaanstailors.com';

          if (isAdmin) {
            context.read<AdminProvider>().setAdmin(
              user.id,
              user.email,
              user.token ?? '',
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
            );
          }
        }
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
                const SizedBox(height: 40),
                const LogoWidget(size: 80),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.headingAccentGradient.createShader(bounds),
                        child: const Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Sign in to continue', style: TextStyle(color: AppColors.gold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  hintText: 'Email Address',
                  controller: _identifierController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email is required' : null,
                ),
                _buildInputField(
                  hintText: 'Password',
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: !_showPassword,
                  onToggleVisibility: () => setState(() => _showPassword = !_showPassword),
                  validator: (v) => v!.isEmpty ? 'Password is required' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                  ),
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
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(text: 'Register Now', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
