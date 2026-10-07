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
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
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

  void _showImageSourceModal(BuildContext context) {
    if (_isPickingImage) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.gold),
              ),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: AppColors.gold),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white70),
              ),
              title: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        final File file = File(pickedFile.path);
        if (file.existsSync()) {
          setState(() {
            _selectedImage = file;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ PICK IMAGE ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not select image'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
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

      // 1. Upload new image if selected
      if (_selectedImage != null && _selectedImage!.existsSync()) {
        debugPrint('UPLOADING PROFILE IMAGE...');
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

    ImageProvider profileImage;
    if (_selectedImage != null && _selectedImage!.existsSync()) {
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
                  GestureDetector(
                    onTap: () => _showImageSourceModal(context),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 57,
                            backgroundColor: Colors.black,
                            backgroundImage: profileImage,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                          ),
                        ),
                      ],
                    ),
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
