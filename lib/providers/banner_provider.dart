import 'dart:io';
import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerProvider with ChangeNotifier {
  final BannerService _bannerService = BannerService();
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  List<BannerModel> get banners => _banners;
  List<BannerModel> get activeBanners => _banners.where((b) => b.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      _banners = await _bannerService.getBanners();
    } catch (e) {
      debugPrint('BannerProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(File imageFile, String token) async {
    return await _bannerService.uploadImage(imageFile, token);
  }

  Future<String?> addBanner(Map<String, dynamic> bannerData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _bannerService.addBanner(bannerData, token);
      if (response['success'] == true) {
        await fetchBanners();
        return null;
      }
      return response['message'] ?? 'Failed to add banner';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateBanner(String id, Map<String, dynamic> bannerData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _bannerService.updateBanner(id, bannerData, token);
      if (response['success'] == true) {
        await fetchBanners();
        return null;
      }
      return response['message'] ?? 'Failed to update banner';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBanner(String id, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _bannerService.deleteBanner(id, token);
      if (success) {
        await fetchBanners();
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBannerStatus(String id, bool status, String token) async {
    await updateBanner(id, {'isActive': status}, token);
  }
}
