import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/measurement_model.dart';
import '../../services/admin/admin_customer_service.dart';

class AdminCustomerProvider with ChangeNotifier {
  List<UserModel> _customers = [];
  List<OrderModel> _selectedCustomerOrders = [];
  List<MeasurementModel> _selectedCustomerMeasurements = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get customers => _customers;
  List<OrderModel> get selectedCustomerOrders => _selectedCustomerOrders;
  List<MeasurementModel> get selectedCustomerMeasurements => _selectedCustomerMeasurements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCustomers(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = AdminCustomerService(token);
      final response = await service.getCustomers();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List customerData = response.data['customers'];
        _customers = customerData.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _error = response.data['message'] ?? 'Failed to fetch customers';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerDetails(String token, String customerId) async {
    _isLoading = true;
    _error = null;
    _selectedCustomerOrders = [];
    _selectedCustomerMeasurements = [];
    notifyListeners();

    try {
      final service = AdminCustomerService(token);
      
      // Fetch Orders
      final ordersRes = await service.getCustomerOrders(customerId);
      if (ordersRes.statusCode == 200 && ordersRes.data['success'] == true) {
        final List orderData = ordersRes.data['orders'];
        _selectedCustomerOrders = orderData.map((json) => OrderModel.fromJson(json)).toList();
      }

      // Fetch Measurements
      final measurementsRes = await service.getCustomerMeasurements(customerId);
      if (measurementsRes.statusCode == 200 && measurementsRes.data['success'] == true) {
        final List measurementData = measurementsRes.data['measurements'];
        _selectedCustomerMeasurements = measurementData.map((json) => MeasurementModel.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
