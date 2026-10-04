import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String? _searchQuery;
  String? _selectedOfferId;
  List<String>? _selectedOfferProductIds;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String? get searchQuery => _searchQuery;
  String? get selectedOfferId => _selectedOfferId;
  List<String>? get selectedOfferProductIds => _selectedOfferProductIds;

  List<Product> get newArrivals {
    if (_allProducts.isEmpty) return [];
    List<Product> sorted = List.from(_allProducts);
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sorted;
  }

  static String normalizeCategory(String cat) {
    final clean = cat.trim().toLowerCase().replaceAll(' ', '').replaceAll('-', '').replaceAll('_', '');

    if (clean == 'all') return 'all';

    // 1. T-Shirts (must come before Shirts)
    if (clean.contains('tshirt') || clean.contains('tshirts')) {
      return 'tshirt';
    }

    // 2. Shirts
    if (clean.contains('shirt') || clean.contains('shirts')) {
      return 'shirt';
    }

    // 3. Pants
    if (clean.contains('pant') || clean.contains('pants') || clean.contains('trouser') || clean.contains('paint')) {
      return 'pant';
    }

    // 4. Suits
    if (clean.contains('suit') || clean.contains('suits')) {
      return 'suit';
    }

    // 5. Uniforms
    if (clean.contains('uniform') || clean.contains('unfome')) {
      return 'uniform';
    }

    // 6. Wedding
    if (clean.contains('wedding')) {
      return 'wedding';
    }

    if (clean.length > 3 && clean.endsWith('s')) {
      return clean.substring(0, clean.length - 1);
    }

    return clean;
  }

  void resetToAll() {
    _selectedOfferId = null;
    _selectedOfferProductIds = null;
    _selectedCategory = 'All';
    _searchQuery = null;
    _applyLocalFilter();
    notifyListeners();
  }

  void applySpecificProductOfferFilter(List<String> productIds, {String? offerId}) {
    _selectedOfferId = offerId;
    _selectedOfferProductIds = productIds;
    _selectedCategory = 'All';
    _searchQuery = null;
    _applyLocalFilter();
    notifyListeners();
  }

  void applyCategoryOfferFilter(String category, {String? offerId, String? categoryId}) {
    _selectedOfferId = offerId;
    _selectedOfferProductIds = null;
    _selectedCategory = category;
    _searchQuery = null;
    if (_allProducts.isEmpty) {
      fetchProducts(category: category);
    } else {
      _applyLocalFilter();
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedOfferId = null;
    _selectedOfferProductIds = null;
    _selectedCategory = category;
    _searchQuery = null;
    if (_allProducts.isEmpty) {
      fetchProducts(category: category);
    } else {
      _applyLocalFilter();
      notifyListeners();
    }
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyLocalFilter();
    notifyListeners();
  }

  Future<void> fetchProducts({String? category, String? search}) async {
    _isLoading = true;
    if (category != null) _selectedCategory = category;
    if (search != null) _searchQuery = search;
    
    notifyListeners();
    try {
      // Fetch all products to allow fast local filtering across categories
      _allProducts = await _productService.getProducts(
        category: 'All', 
        search: null
      );
      _applyLocalFilter();
    } catch (e) {
      debugPrint('ProductProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyLocalFilter() {
    if (_selectedOfferProductIds != null && _selectedOfferProductIds!.isNotEmpty) {
      final targetIds = _selectedOfferProductIds!.toSet();
      _filteredProducts = _allProducts.where((p) => targetIds.contains(p.id)).toList();
      return;
    }

    final selectedClean = _selectedCategory.trim().toLowerCase();
    
    if (selectedClean == 'all') {
      _filteredProducts = List.from(_allProducts);
    } else {
      final targetNormalized = normalizeCategory(_selectedCategory);
      
      _filteredProducts = _allProducts.where((product) {
        final productNormalized = normalizeCategory(product.category);
        return productNormalized == targetNormalized;
      }).toList();
    }

    if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
      final query = _searchQuery!.trim().toLowerCase();
      _filteredProducts = _filteredProducts.where((product) {
        final nameMatch = product.name.toLowerCase().contains(query);
        final descMatch = product.description.toLowerCase().contains(query);
        final catMatch = product.category.toLowerCase().contains(query);
        final fabricMatch = product.fabric.toLowerCase().contains(query);
        return nameMatch || descMatch || catMatch || fabricMatch;
      }).toList();
    }
  }

  void applyFilters({
    List<String>? categories,
    List<String>? fabrics,
    String? priceRange,
    List<String>? sizes,
    List<String>? colors,
  }) {
    _filteredProducts = _allProducts.where((product) {
      // Category Filter
      if (categories != null && categories.isNotEmpty) {
        final normProductCat = normalizeCategory(product.category);
        final normFilterCats = categories.map((c) => normalizeCategory(c)).toSet();
        if (!normFilterCats.contains(normProductCat)) return false;
      }

      // Fabric Filter
      if (fabrics != null && fabrics.isNotEmpty) {
        final normProductFabric = product.fabric.trim().toLowerCase();
        final normFilterFabrics = fabrics.map((f) => f.trim().toLowerCase()).toSet();
        if (!normFilterFabrics.contains(normProductFabric)) return false;
      }

      // Price Filter
      if (priceRange != null) {
        if (priceRange == 'Under ₹500') {
          if (product.price >= 500) return false;
        } else if (priceRange == '₹500 – ₹1000') {
          if (product.price < 500 || product.price > 1000) return false;
        } else if (priceRange == '₹1000 – ₹2000') {
          if (product.price < 1000 || product.price > 2000) return false;
        } else if (priceRange == 'Above ₹2000') {
          if (product.price <= 2000) return false;
        }
      }

      // Size Filter
      if (sizes != null && sizes.isNotEmpty) {
        bool hasSize = product.sizes.any((s) => sizes.contains(s));
        if (!hasSize) return false;
      }

      // Color Filter
      if (colors != null && colors.isNotEmpty) {
        bool hasColor = product.colors.any((c) => colors.contains(c));
        if (!hasColor) return false;
      }

      return true;
    }).toList();
    notifyListeners();
  }

  void applySort(String sortType) {
    if (sortType == 'Price: Low to High') {
      _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == 'Price: High to Low') {
      _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortType == 'Newest') {
      _filteredProducts.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    } else if (sortType == 'Rating: High to Low') {
      _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }
    notifyListeners();
  }

  Future<List<String>> uploadImages(List<File> imageFiles, String token) async {
    try {
      return await _productService.uploadImages(imageFiles, token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.addProduct(productData, token);
      await fetchProducts(); // Refresh list
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> productData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.updateProduct(id, productData, token);
      await fetchProducts(); // Refresh list
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStock(String id, int stock, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.updateProduct(id, {'stock': stock}, token);
      await fetchProducts(); // Refresh list
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _productService.deleteProduct(id, token);
      if (success) {
        await fetchProducts();
      }
      return success;
    } catch (e) {
      debugPrint('Delete Product Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
