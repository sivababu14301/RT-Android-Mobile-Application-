import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> login(String email, String password) async {
    _setLoading(true);
    debugPrint('--- USER PROVIDER LOGIN ---');
    
    try {
      final response = await _authService.login(email: email, password: password);
      
      if (response.data != null && response.data['success'] == true) {
        final userData = response.data['user'];
        final String? token = response.data['token'];
        final String message = response.data['message'] ?? 'Login successful';
        
        _user = UserModel.fromJson(userData);
        if (token != null) {
          _user = UserModel(
            id: _user!.id,
            fullName: _user!.fullName,
            email: _user!.email,
            mobile: _user!.mobile,
            profileImage: _user!.profileImage,
            role: _user!.role,
            address: _user!.address,
            token: token,
          );
          
          // Persist token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        
        debugPrint('LOGIN DATA PARSED: Role: ${_user!.role}');

        // Immediately fetch full profile
        await fetchProfile();
        
        return message;
      } else {
        // This case handles success: false from backend even if 2xx status
        final errorMsg = response.data['message'] ?? 'Login failed';
        debugPrint('LOGIN DATA FAILED FLAG: $errorMsg');
        throw errorMsg;
      }
    } catch (e) {
      debugPrint('❌ USER PROVIDER LOGIN CATCH: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String fullName, String email, String mobile, String password, String rememberAccess) async {
    _setLoading(true);
    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        mobile: mobile,
        password: password,
        rememberAccess: rememberAccess,
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    if (_user?.token == null) return;
    try {
      final userService = UserService(_user!.token!);
      final response = await userService.getProfile();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final String? currentToken = _user!.token;
        _user = UserModel.fromJson(response.data['user']);
        // Always preserve the token
        _user = UserModel(
          id: _user!.id,
          fullName: _user!.fullName,
          email: _user!.email,
          mobile: _user!.mobile,
          profileImage: _user!.profileImage,
          role: _user!.role,
          address: _user!.address,
          token: currentToken,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<bool> checkAuthState() async {
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        _user = UserModel(
          id: '',
          fullName: '',
          email: '',
          mobile: '',
          token: token,
        );
        
        final userService = UserService(token);
        final response = await userService.getProfile();
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          _user = UserModel.fromJson(response.data['user']);
          _user = UserModel(
            id: _user!.id,
            fullName: _user!.fullName,
            email: _user!.email,
            mobile: _user!.mobile,
            profileImage: _user!.profileImage,
            role: _user!.role,
            address: _user!.address,
            token: token,
          );
          notifyListeners();
          return true;
        } else {
          await prefs.remove('token');
          _user = null;
        }
      }
    } catch (e) {
      debugPrint('Auth Check Error: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({required String fullName, required String email, required String mobile}) async {
    if (_user?.token == null) return;
    _setLoading(true);
    try {
      final userService = UserService(_user!.token!);
      await userService.updateProfile(name: fullName, email: email, mobile: mobile);
      await fetchProfile();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfilePic(File image) async {
    if (_user?.token == null) return;
    _setLoading(true);
    try {
      final userService = UserService(_user!.token!);
      await userService.uploadProfilePic(image);
      await fetchProfile();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (_user?.token == null) return;
    _setLoading(true);
    try {
      final userService = UserService(_user!.token!);
      await userService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    if (_user?.token == null) return;
    _setLoading(true);
    try {
      final userService = UserService(_user!.token!);
      await userService.updateAddress(address.toJson());
      await fetchProfile();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAddress() async {
    if (_user?.token == null) return;
    _setLoading(true);
    try {
      final userService = UserService(_user!.token!);
      await userService.deleteAddress();
      await fetchProfile();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
