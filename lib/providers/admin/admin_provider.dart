import 'package:flutter/material.dart';
import '../../models/admin/admin_model.dart';
import '../../models/admin/dashboard_stats_model.dart';
import '../../services/auth_service.dart';
import '../../services/admin/admin_dashboard_service.dart';

class AdminProvider with ChangeNotifier {
  AdminModel? _admin;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  DashboardStatsModel? _stats;
  final AuthService _authService = AuthService();

  AdminModel? get admin => _admin;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  DashboardStatsModel? get stats => _stats;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    debugPrint('--- ADMIN PROVIDER LOGIN ---');
    try {
      final response = await _authService.login(email: email, password: password);
      
      if (response.data != null && response.data['success'] == true) {
        final userData = response.data['user'];
        final String token = response.data['token'];
        final String role = (userData['role'] ?? 'user').toString().toLowerCase();

        if (role != 'admin') {
          debugPrint('❌ ACCESS DENIED: User role is $role');
          return 'Access Denied: You do not have admin privileges.';
        }

        _admin = AdminModel(
          id: userData['_id'],
          email: userData['email'],
          token: token,
        );
        _isAuthenticated = true;
        
        debugPrint('ADMIN LOGIN SUCCESSFUL');
        return null; // Success
      }
      return response.data['message'] ?? 'Invalid credentials';
    } catch (e) {
      debugPrint('❌ ADMIN PROVIDER LOGIN CATCH: $e');
      // If e is "Login successful", we have a logic loop, but here it's caught from AuthService throw
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAdmin(String id, String email, String token) {
    _admin = AdminModel(
      id: id,
      email: email,
      token: token,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _admin = null;
    _isAuthenticated = false;
    _stats = null;
    notifyListeners();
  }

  Future<void> fetchDashboardStats() async {
    if (_admin?.token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final service = AdminDashboardService(_admin!.token);
      final response = await service.getStats();
      if (response.statusCode == 200 && response.data['success'] == true) {
        _stats = DashboardStatsModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
