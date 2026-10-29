import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => [..._orders];
  List<OrderModel> get cancellationRequests => _orders.where((o) => o.status == 'Cancellation Requested').toList();
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
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> cancelOrder(String id, String token) async {
    return await requestOrderCancellation(id, token);
  }

  Future<Map<String, dynamic>> requestOrderCancellation(String id, String token, {String? reason}) async {
    try {
      final service = OrderService(token);
      final response = await service.cancelOrder(id, reason);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return {
          'success': true,
          'message': response.data['message'] ?? 'Your cancellation request has been sent to the admin for approval.',
        };
      }

      String errorMsg = 'Order cancellation is not allowed as order processing has already started.';
      if (response.data is Map && response.data['message'] != null) {
        errorMsg = response.data['message'];
      }
      return {'success': false, 'message': errorMsg};
    } catch (e) {
      debugPrint('Error requesting order cancellation: $e');
      return {
        'success': false,
        'message': 'Cancellation is not allowed as order processing has already started.',
      };
    }
  }

  Future<Map<String, dynamic>> approveOrderCancellation(String id, String token) async {
    try {
      final service = OrderService(token);
      final response = await service.approveOrderCancellation(id);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return {
          'success': true,
          'message': response.data['message'] ?? 'Cancellation approved successfully.',
        };
      }
      return {'success': false, 'message': response.data['message'] ?? 'Failed to approve cancellation.'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rejectOrderCancellation(String id, String token, {String? reason}) async {
    try {
      final service = OrderService(token);
      final response = await service.rejectOrderCancellation(id, reason);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return {
          'success': true,
          'message': response.data['message'] ?? 'Cancellation request rejected.',
        };
      }
      return {'success': false, 'message': response.data['message'] ?? 'Failed to reject cancellation.'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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

  Future<Map<String, dynamic>> updateStatus(String id, String status, String token) async {
    try {
      final service = OrderService(token);
      final response = await service.updateOrderStatus(id, status);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = OrderModel.fromJson(response.data['order']);
          notifyListeners();
        }
        return {'success': true, 'message': 'Status updated successfully'};
      }
      String msg = 'Failed to update status';
      if (response.data is Map && response.data['message'] != null) {
        msg = response.data['message'];
      }
      return {'success': false, 'message': msg};
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return {'success': false, 'message': 'Failed to update status.'};
    }
  }
}
