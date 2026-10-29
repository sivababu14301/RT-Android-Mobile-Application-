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

    // 1. Formal Shirts (must come before Shirts)
    if (clean.contains('formalshirt') || clean.contains('formalshirts')) {
      return 'formalshirt';
    }

    // 2. T-Shirts (must come before Shirts)
    if (clean.contains('tshirt') || clean.contains('tshirts')) {
      return 'tshirt';
    }

    // 3. Shirts
    if (clean.contains('shirt') || clean.contains('shirts')) {
      return 'shirt';
    }

    // 4. Jeans
    if (clean.contains('jean') || clean.contains('jeans')) {
      return 'jean';
    }

    // 5. Pants & Trousers
    if (clean.contains('pant') || clean.contains('pants') || clean.contains('trouser') || clean.contains('trousers') || clean.contains('paint')) {
      return 'pant';
    }

    // 6. Blazers
    if (clean.contains('blazer') || clean.contains('blazers')) {
      return 'blazer';
    }

    // 7. Suits
    if (clean.contains('suit') || clean.contains('suits')) {
      return 'suit';
    }

    // 8. School Uniforms
    if (clean.contains('school')) {
      return 'schooluniform';
    }

    // 9. College Uniforms
    if (clean.contains('college')) {
      return 'collegeuniform';
    }

    // 10. Uniforms (General)
    if (clean.contains('uniform') || clean.contains('unfome')) {
      return 'uniform';
    }

    // 11. Wedding Wear
    if (clean.contains('wedding')) {
      return 'wedding';
    }

    // 12. Casual Wear
    if (clean.contains('casual')) {
      return 'casualwear';
    }

    // 13. Traditional Wear
    if (clean.contains('traditional') || clean.contains('ethnic')) {
      return 'traditionalwear';
    }

    // 14. Shorts
    if (clean.contains('short') || clean.contains('shorts')) {
      return 'short';
    }

    // 15. Jackets
    if (clean.contains('jacket') || clean.contains('jackets')) {
      return 'jacket';
    }

    // 16. Accessories
    if (clean.contains('accessor')) {
      return 'accessory';
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
      final rawTargetLower = _selectedCategory.trim().toLowerCase();
      
      _filteredProducts = _allProducts.where((product) {
        final productCatNormalized = normalizeCategory(product.category);
        if (productCatNormalized == targetNormalized) return true;
        
        final rawProductCat = product.category.trim().toLowerCase();
        
        if (targetNormalized == 'pant') {
          return rawProductCat.contains('pant') || rawProductCat.contains('trouser') || rawProductCat.contains('paint');
        }
        if (targetNormalized == 'shirt') {
          return rawProductCat.contains('shirt') && !rawProductCat.contains('tshirt') && !rawProductCat.contains('t-shirt') && !rawProductCat.contains('formal');
        }
        if (targetNormalized == 'tshirt') {
          return rawProductCat.contains('tshirt') || rawProductCat.contains('t-shirt');
        }
        if (targetNormalized == 'formalshirt') {
          return rawProductCat.contains('formal') && rawProductCat.contains('shirt');
        }
        if (targetNormalized == 'jean') {
          return rawProductCat.contains('jean');
        }
        if (targetNormalized == 'blazer') {
          return rawProductCat.contains('blazer');
        }
        if (targetNormalized == 'suit') {
          return rawProductCat.contains('suit');
        }
        if (targetNormalized == 'schooluniform') {
          return rawProductCat.contains('school');
        }
        if (targetNormalized == 'collegeuniform') {
          return rawProductCat.contains('college');
        }
        if (targetNormalized == 'wedding') {
          return rawProductCat.contains('wedding');
        }
        
        return rawProductCat.contains(rawTargetLower);
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

      // Price Range Filter
      if (priceRange != null && priceRange.isNotEmpty) {
        final price = product.price;
        if (priceRange == 'Under ₹500' && price >= 500) return false;
        if (priceRange == '₹500 – ₹1000' && (price < 500 || price > 1000)) return false;
        if (priceRange == '₹1000 – ₹2000' && (price < 1000 || price > 2000)) return false;
        if (priceRange == 'Above ₹2000' && price <= 2000) return false;
      }

      // Size Filter
      if (sizes != null && sizes.isNotEmpty) {
        final productSizes = product.displaySizes.map((s) => s.trim().toUpperCase()).toSet();
        final filterSizes = sizes.map((s) => s.trim().toUpperCase()).toSet();
        if (productSizes.intersection(filterSizes).isEmpty) return false;
      }

      // Color Filter
      if (colors != null && colors.isNotEmpty) {
        final productColors = product.colors.map((c) => c.trim().toLowerCase()).toSet();
        final filterColors = colors.map((c) => c.trim().toLowerCase()).toSet();
        if (productColors.intersection(filterColors).isEmpty) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void applySort(String sortOption) {
    if (sortOption == 'Price: Low to High') {
      _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == 'Price: High to Low') {
      _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortOption == 'Newest') {
      _filteredProducts.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    } else if (sortOption == 'Rating: High to Low') {
      _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }
    notifyListeners();
  }

  // Admin Methods
  Future<List<String>> uploadImages(List<File> imageFiles, String token) async {
    return await _productService.uploadImages(imageFiles, token);
  }

  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData, String token) async {
    final result = await _productService.addProduct(productData, token);
    await fetchProducts();
    return result;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData, String token) async {
    final result = await _productService.updateProduct(id, productData, token);
    await fetchProducts();
    return result;
  }

  Future<bool> deleteProduct(String id, String token) async {
    final success = await _productService.deleteProduct(id, token);
    if (success) {
      await fetchProducts();
    }
    return success;
  }
}
