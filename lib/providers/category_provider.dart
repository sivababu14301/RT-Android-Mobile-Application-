import 'package:flutter/material.dart';
import 'dart:io';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      debugPrint('CategoryProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(File imageFile, String token) async {
    return await _categoryService.uploadImage(imageFile, token);
  }

  Future<String?> addCategory(Map<String, dynamic> categoryData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _categoryService.addCategory(categoryData, token);
      if (response['success'] == true) {
        await fetchCategories();
        return null; // Success
      }
      return response['message'] ?? 'Failed to add category';
    } catch (e) {
      debugPrint('Add Category Error: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateCategory(String id, Map<String, dynamic> categoryData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _categoryService.updateCategory(id, categoryData, token);
      if (response['success'] == true) {
        await fetchCategories();
        return null; // Success
      }
      return response['message'] ?? 'Failed to update category';
    } catch (e) {
      debugPrint('Update Category Error: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String id, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _categoryService.deleteCategory(id, token);
      if (success) {
        await fetchCategories();
      }
      return success;
    } catch (e) {
      debugPrint('Delete Category Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
