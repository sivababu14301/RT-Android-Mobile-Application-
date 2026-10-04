import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchMyOrders(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final service = OrderService(token);
      final response = await service.getMyOrders();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List ordersJson = response.data['orders'];
        _orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> placeOrder(Map<String, dynamic> orderData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final service = OrderService(token);
      final response = await service.createOrder(orderData);
      if (response.statusCode == 201 && response.data['success'] == true) {
        final newOrder = OrderModel.fromJson(response.data['order']);
        _orders.insert(0, newOrder);
        notifyListeners();
        return newOrder;
      }
      return null;
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow; // Rethrow to allow UI to catch and show the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String id, String token) async {
    try {
      final service = OrderService(token);
      final response = await service.cancelOrder(id);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  // Admin methods
  Future<void> fetchAllOrders(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final service = OrderService(token);
      final response = await service.getAllOrders();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List ordersJson = response.data['orders'];
        _orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String id, String status, String token) async {
    try {
      final service = OrderService(token);
      final response = await service.updateOrderStatus(id, status);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }
}
