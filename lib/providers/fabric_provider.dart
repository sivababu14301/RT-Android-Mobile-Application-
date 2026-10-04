import 'package:flutter/material.dart';
import '../models/fabric_model.dart';
import '../services/fabric_service.dart';

class FabricProvider with ChangeNotifier {
  final FabricService _service = FabricService();

  List<FabricModel> _activeFabrics = [];
  List<FabricModel> _allFabrics = [];
  bool _isLoading = false;

  List<FabricModel> get activeFabrics => _activeFabrics;
  List<FabricModel> get allFabrics => _allFabrics;
  bool get isLoading => _isLoading;

  Future<void> fetchActiveFabrics() async {
    _isLoading = true;
    notifyListeners();

    _activeFabrics = await _service.getActiveFabrics();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllFabrics(String token) async {
    _isLoading = true;
    notifyListeners();

    _allFabrics = await _service.getAllFabrics(token);
    _activeFabrics = _allFabrics.where((f) => f.isActive).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleFabricStatus(String id, bool isActive, String token) async {
    final result = await _service.updateFabric(id, {'isActive': isActive}, token);
    if (result['success'] == true) {
      await fetchAllFabrics(token);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> addFabric(String name, String token) async {
    final result = await _service.addFabric(name, true, token);
    if (result['success'] == true) {
      await fetchAllFabrics(token);
    }
    return result;
  }

  Future<Map<String, dynamic>> updateFabricName(String id, String newName, String token) async {
    final result = await _service.updateFabric(id, {'name': newName}, token);
    if (result['success'] == true) {
      await fetchAllFabrics(token);
    }
    return result;
  }

  Future<Map<String, dynamic>> deleteFabric(String id, String token) async {
    final result = await _service.deleteFabric(id, token);
    if (result['success'] == true) {
      await fetchAllFabrics(token);
    }
    return result;
  }
}
