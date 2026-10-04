import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_currentController.text.isEmpty || _newController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.changePassword(_currentController.text, _newController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Current Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: _currentController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'New Password',
              prefixIcon: Icons.lock_reset_outlined,
              isPassword: true,
              controller: _newController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Confirm New Password',
              prefixIcon: Icons.lock_clock_outlined,
              isPassword: true,
              controller: _confirmController,
            ),
            const SizedBox(height: 32),
            userProvider.isLoading
                ? const CircularProgressIndicator(color: AppColors.gold)
                : CustomButton(
                    text: 'UPDATE PASSWORD',
                    onPressed: _handleChangePassword,
                  ),
          ],
        ),
      ),
    );
  }
}
