import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../providers/admin/admin_profile_provider.dart';
import '../../../widgets/admin/profile/profile_avatar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _gstController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AdminProfileProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _shopNameController = TextEditingController(text: profile.shopName);
    _addressController = TextEditingController(text: profile.shopAddress);
    _gstController = TextEditingController(text: profile.gstNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final provider = Provider.of<AdminProfileProvider>(context, listen: false);
    final updatedProfile = provider.profile.copyWith(
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      shopName: _shopNameController.text,
      shopAddress: _addressController.text,
      gstNumber: _gstController.text,
    );
    provider.updateProfile(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Consumer<AdminProfileProvider>(
              builder: (context, provider, child) => ProfileAvatar(
                imageUrl: provider.profile.profilePhoto ?? 'https://ui-avatars.com/api/?name=Admin&background=D4AF37&color=0D0D0D&bold=true',
                onCameraTap: () {},
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            CustomTextField(
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
            ),
            CustomTextField(
              hintText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              controller: _phoneController,
            ),
            CustomTextField(
              hintText: 'Shop Name',
              prefixIcon: Icons.storefront_outlined,
              controller: _shopNameController,
            ),
            CustomTextField(
              hintText: 'Shop Address',
              prefixIcon: Icons.location_on_outlined,
              controller: _addressController,
            ),
            CustomTextField(
              hintText: 'GST Number',
              prefixIcon: Icons.description_outlined,
              controller: _gstController,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'SAVE CHANGES',
              onPressed: _saveChanges,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
