import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Current Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: _currentController,
            ),
            CustomTextField(
              hintText: 'New Password',
              prefixIcon: Icons.lock_reset,
              isPassword: true,
              controller: _newController,
            ),
            CustomTextField(
              hintText: 'Confirm New Password',
              prefixIcon: Icons.lock_clock_outlined,
              isPassword: true,
              controller: _confirmController,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'UPDATE PASSWORD',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
