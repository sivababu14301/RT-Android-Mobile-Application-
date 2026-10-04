import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Load initial data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Ensure we have fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userProvider.fetchProfile();
      _loadUserData();
    });
    
    _loadUserData();
  }
  
  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.mobile;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      debugPrint('PROFILE UPDATE - NAME: ${_nameController.text}');
      debugPrint('PROFILE UPDATE - EMAIL: ${_emailController.text}');
      debugPrint('PROFILE UPDATE - MOBILE: ${_phoneController.text}');

      // 1. Upload image if selected
      if (_selectedImage != null) {
        debugPrint('UPLOADING NEW PROFILE IMAGE...');
        await userProvider.updateProfilePic(_selectedImage!);
      }

      // 2. Update text details
      debugPrint('SENDING PROFILE UPDATE REQUEST...');
      await userProvider.updateProfile(
        fullName: _nameController.text,
        email: _emailController.text,
        mobile: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ PROFILE UPDATE ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Build the image provider logic
    ImageProvider profileImage;
    if (_selectedImage != null) {
      profileImage = FileImage(_selectedImage!);
    } else {
      profileImage = NetworkImage(user?.getProfileImage ?? 'https://ui-avatars.com/api/?name=User&background=D4AF37&color=0D0D0D&bold=true');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold), 
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: userProvider.isLoading && user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.gold,
                        child: CircleAvatar(radius: 57, backgroundImage: profileImage),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    hintText: 'Full Name', 
                    prefixIcon: Icons.person_outline, 
                    controller: _nameController
                  ),
                  CustomTextField(
                    hintText: 'Email Address', 
                    prefixIcon: Icons.email_outlined, 
                    controller: _emailController
                  ),
                  CustomTextField(
                    hintText: 'Phone Number', 
                    prefixIcon: Icons.phone_outlined, 
                    controller: _phoneController
                  ),
                  const SizedBox(height: 32),
                  userProvider.isLoading
                      ? const CircularProgressIndicator(color: AppColors.gold)
                      : CustomButton(text: 'SAVE CHANGES', onPressed: _saveProfile),
                ],
              ),
            ),
    );
  }
}
