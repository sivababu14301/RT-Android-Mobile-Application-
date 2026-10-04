import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartItemModel {
  final Product product;
  int quantity;
  final String? size;
  final String? color;

  CartItemModel({required this.product, required this.quantity, this.size, this.color});

  double get total => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => [..._items];
  bool get isLoading => _isLoading;

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  // Alias for compatibility
  double get totalAmount => subtotal;

  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final service = CartService(token);
      final response = await service.getCart();
      
      debugPrint("GET CART RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List itemsJson = response.data['cart']['items'] ?? [];
        _items = itemsJson.map((item) {
          return CartItemModel(
            product: Product.fromJson(item['productId']),
            quantity: item['quantity'],
            size: item['size'],
            color: item['color'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(Product product, String token, {int quantity = 1, String? size, String? color}) async {
    try {
      final service = CartService(token);
      final response = await service.addToCart(product.id, quantity, size: size, color: color);
      
      debugPrint("CART ADD STATUS: ${response.statusCode}");
      debugPrint("CART ADD RESPONSE: ${response.data}");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        // Update local state or re-fetch
        final existingIndex = _items.indexWhere((item) => 
          item.product.id == product.id && 
          item.size == size && 
          item.color == color
        );
        
        if (existingIndex > -1) {
          _items[existingIndex].quantity += quantity;
        } else {
          _items.add(CartItemModel(product: product, quantity: quantity, size: size, color: color));
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      return false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity, String token) async {
    try {
      final service = CartService(token);
      final response = await service.updateQuantity(productId, quantity);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _items.indexWhere((item) => item.product.id == productId);
        if (index > -1) {
          if (quantity > 0) {
            _items[index].quantity = quantity;
          } else {
            _items.removeAt(index);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error updating quantity: $e");
    }
  }

  Future<void> removeFromCart(String productId, String token) async {
    try {
      final service = CartService(token);
      final response = await service.removeFromCart(productId);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        _items.removeWhere((item) => item.product.id == productId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  Future<void> clearCart(String token) async {
    try {
      final service = CartService(token);
      final response = await service.clearCart();
      if (response.statusCode == 200) {
        _items.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }

  // Alias for compatibility
  void clear(String token) => clearCart(token);
}
