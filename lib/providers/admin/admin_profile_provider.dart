import 'package:flutter/material.dart';
import '../../models/admin/admin_profile_model.dart';

class AdminProfileProvider with ChangeNotifier {
  AdminProfileModel _profile = AdminProfileModel(
    id: 'ADM001',
    fullName: 'Siva Prasanth',
    email: 'admin@raymaanstailors.com',
    phoneNumber: '+91 9444024411',
    shopName: 'Raymaans Tailors',
    shopAddress: 'Raymaans Tailors, Eriyur, Sunchalnatham (PO), Pennagaram Taluk, Dharmapuri District – 636810, Tamil Nadu, India.',
    gstNumber: '33AAAAA0000A1Z5',
    profilePhoto: 'https://ui-avatars.com/api/?name=Admin&background=D4AF37&color=0D0D0D&bold=true',
  );

  AdminProfileModel get profile => _profile;

  void updateProfile(AdminProfileModel newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
