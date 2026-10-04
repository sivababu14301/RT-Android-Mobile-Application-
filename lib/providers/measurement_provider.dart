import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/measurement_model.dart';
import '../services/measurement_service.dart';

class MeasurementProvider with ChangeNotifier {
  List<MeasurementModel> _measurements = [];
  bool _isLoading = false;
  String? _error;

  List<MeasurementModel> get measurements => _measurements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasSavedShirtMeasurements => _measurements.any((m) => m.type == 'shirt');
  bool get hasSavedPantMeasurements => _measurements.any((m) => m.type == 'pant');

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchMyMeasurements(String token) async {
    _setLoading(true);
    _error = null;
    try {
      final service = MeasurementService(token);
      final response = await service.getMyMeasurements();
      
      debugPrint("GET MEASUREMENTS RESPONSE: ${response.data}");

      if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
        final List list = response.data['measurements'] ?? [];
        _measurements = list.map((m) => MeasurementModel.fromJson(m)).toList();
      } else {
        _error = response.data is Map ? response.data['message'] : 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveMeasurement(MeasurementModel measurement, String token) async {
    _setLoading(true);
    _error = null;
    try {
      final service = MeasurementService(token);
      
      // Check if measurement of this type already exists for update, or create new
      final existingIndex = _measurements.indexWhere((m) => m.type == measurement.type);
      
      Response response;
      if (existingIndex != -1 && _measurements[existingIndex].id != null) {
        debugPrint("UPDATING EXISTING MEASUREMENT ID: ${_measurements[existingIndex].id}");
        response = await service.updateMeasurement(_measurements[existingIndex].id!, measurement);
      } else {
        debugPrint("CREATING NEW MEASUREMENT");
        response = await service.createMeasurement(measurement);
      }

      print("SAVE STATUS: ${response.statusCode}");
      print("SAVE RESPONSE: ${response.data}");

      if ((response.statusCode == 201 || response.statusCode == 200) && response.data['success'] == true) {
        // Success means MongoDB save succeeded
        await fetchMyMeasurements(token);
        return true;
      } else {
        _error = response.data is Map ? response.data['message'] : 'Save failed';
        return false;
      }
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMeasurement(String id, String token) async {
    _setLoading(true);
    _error = null;
    try {
      final service = MeasurementService(token);
      final response = await service.deleteMeasurement(id);
      if (response.statusCode == 200) {
        await fetchMyMeasurements(token);
        return true;
      } else {
        _error = response.data is Map ? response.data['message'] : 'Delete failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
