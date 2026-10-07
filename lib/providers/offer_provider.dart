import 'dart:io';
import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../services/offer_service.dart';
import '../services/local_notification_service.dart';

class OfferProvider with ChangeNotifier {
  final OfferService _offerService = OfferService();
  List<OfferModel> _offers = [];
  bool _isLoading = false;

  List<OfferModel> get allOffers => [..._offers];
  bool get isLoading => _isLoading;
  
  List<OfferModel> get activeOffers {
    return _offers.where((offer) => offer.isEffectivelyActive).toList();
  }

  Future<void> fetchOffers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _offers = await _offerService.getOffers();
      // Check for new unseen offers and trigger local notification
      LocalNotificationService.instance.checkAndNotifyNewOffers(_offers);
    } catch (e) {
      debugPrint('OfferProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(File imageFile, String token) async {
    return await _offerService.uploadImage(imageFile, token);
  }

  Future<String?> addOffer(Map<String, dynamic> offerData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _offerService.addOffer(offerData, token);
      if (response['success'] == true) {
        await fetchOffers();
        return null;
      }
      return response['message'] ?? 'Failed to add offer';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateOffer(String id, Map<String, dynamic> offerData, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _offerService.updateOffer(id, offerData, token);
      if (response['success'] == true) {
        await fetchOffers();
        return null;
      }
      return response['message'] ?? 'Failed to update offer';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOffer(String id, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _offerService.deleteOffer(id, token);
      if (success) {
        await fetchOffers();
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleOfferStatus(String id, bool status, String token) async {
    await updateOffer(id, {'isActive': status}, token);
  }
}
