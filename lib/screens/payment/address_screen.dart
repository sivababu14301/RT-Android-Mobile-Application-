import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import 'payment_screen.dart';
import 'add_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final address = userProvider.user?.address;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Address',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (address == null)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off_outlined, size: 80, color: AppColors.grey),
                          const SizedBox(height: 20),
                          const Text(
                            'No address found',
                            style: TextStyle(color: AppColors.grey, fontSize: 18),
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: 'ADD NEW ADDRESS',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddAddressScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Delivery Address',
                                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddAddressScreen(address: address)),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => userProvider.deleteAddress(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),
                            Text(address.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(address.mobile, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 12),
                            Text(
                              address.formattedAddress,
                              style: const TextStyle(color: Colors.white70, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'PROCEED TO PAYMENT',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
