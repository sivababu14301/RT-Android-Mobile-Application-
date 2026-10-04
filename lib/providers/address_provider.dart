import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<AddressModel> _addresses = [
    AddressModel(
      id: '1',
      fullName: 'Siva B',
      mobile: '9876543210',
      houseNo: 'No. 12',
      street: 'Main Street',
      area: 'Raymaans Area',
      city: 'Dharmapuri',
      state: 'Tamil Nadu',
      pincode: '636701',
    ),
  ];

  List<AddressModel> get addresses => [..._addresses];

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress ?? (_addresses.isNotEmpty ? _addresses[0] : null);

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    _addresses.add(address);
    notifyListeners();
  }
}
