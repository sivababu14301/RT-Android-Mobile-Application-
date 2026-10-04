import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _doorNoController;
  late TextEditingController _streetController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.fullName ?? '');
    _mobileController = TextEditingController(text: widget.address?.mobile ?? '');
    _doorNoController = TextEditingController(text: widget.address?.doorNo ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _areaController = TextEditingController(text: widget.address?.area ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _doorNoController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        fullName: _nameController.text,
        mobile: _mobileController.text,
        doorNo: _doorNoController.text,
        street: _streetController.text,
        area: _areaController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
      );

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateAddress(newAddress);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address saved successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Full Name', Icons.person_outline),
              _buildTextField(_mobileController, 'Mobile Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_doorNoController, 'Door / House No', Icons.home_outlined),
              _buildTextField(_streetController, 'Street / Road', Icons.add_road),
              _buildTextField(_areaController, 'Area / Colony', Icons.location_on_outlined),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              _buildTextField(_stateController, 'State', Icons.map_outlined),
              const SizedBox(height: 32),
              userProvider.isLoading
                  ? const CircularProgressIndicator(color: AppColors.gold)
                  : CustomButton(text: 'SAVE ADDRESS', onPressed: _saveAddress),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
