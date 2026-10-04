import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  List<Product> _wishlistItems = [];
  bool _isLoading = false;

  List<Product> get items => [..._wishlistItems];
  int get itemCount => _wishlistItems.length;
  bool get isLoading => _isLoading;

  bool isFavorite(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  Future<void> fetchWishlist(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final service = WishlistService(token);
      final response = await service.getWishlist();
      
      debugPrint("GET MY WISHLIST RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List productsJson = response.data['wishlist']['products'] ?? [];
        _wishlistItems = productsJson.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching wishlist: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToWishlist(Product product, String token) async {
    final service = WishlistService(token);
    try {
      debugPrint("ADDING TO WISHLIST: ${product.id}");
      final response = await service.addToWishlist(product.id);
      
      debugPrint("WISHLIST STATUS: ${response.statusCode}");
      debugPrint("WISHLIST RESPONSE: ${response.data}");

      if (response.statusCode == 201 && response.data['success'] == true) {
        _wishlistItems.add(product);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error adding to wishlist: $e");
      return false;
    }
  }

  Future<bool> removeFromWishlist(String productId, String token) async {
    final service = WishlistService(token);
    try {
      debugPrint("REMOVING FROM WISHLIST: $productId");
      final response = await service.removeFromWishlist(productId);
      
      debugPrint("WISHLIST STATUS: ${response.statusCode}");
      debugPrint("WISHLIST RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        _wishlistItems.removeWhere((item) => item.id == productId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error removing from wishlist: $e");
      return false;
    }
  }

  void clear() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
