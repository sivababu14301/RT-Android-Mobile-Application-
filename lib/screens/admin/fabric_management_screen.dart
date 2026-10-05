import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/fabric_model.dart';
import '../../providers/fabric_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin/admin_provider.dart';

class FabricManagementScreen extends StatefulWidget {
  const FabricManagementScreen({super.key});

  @override
  State<FabricManagementScreen> createState() => _FabricManagementScreenState();
}

class _FabricManagementScreenState extends State<FabricManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminProvider>().admin?.token ?? context.read<UserProvider>().user?.token;
      if (token != null) {
        context.read<FabricProvider>().fetchAllFabrics(token);
      }
    });
  }

  void _showAddEditDialog({FabricModel? fabric}) {
    final nameController = TextEditingController(text: fabric?.name ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
          ),
          title: Text(
            fabric == null ? 'Add New Fabric' : 'Edit Fabric Name',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Fabric Name',
                labelStyle: const TextStyle(color: AppColors.gold),
                hintText: 'e.g. Cotton, Silk, Velvet',
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter fabric name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final token = context.read<AdminProvider>().admin?.token ?? context.read<UserProvider>().user?.token;
                  if (token == null) return;

                  final fabricProvider = context.read<FabricProvider>();
                  final name = nameController.text.trim();

                  Navigator.pop(context); // Close dialog

                  Map<String, dynamic> result;
                  if (fabric == null) {
                    result = await fabricProvider.addFabric(name, token);
                  } else {
                    result = await fabricProvider.updateFabricName(fabric.id, name, token);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? (result['success'] == true ? 'Fabric saved' : 'Failed to save'),
                        ),
                        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(FabricModel fabric) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Delete Fabric', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete "${fabric.name}"?\n\nIf it is used by existing products, it cannot be deleted.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = context.read<AdminProvider>().admin?.token ?? context.read<UserProvider>().user?.token;
                if (token == null) return;

                Navigator.pop(context);

                final result = await context.read<FabricProvider>().deleteFabric(fabric.id, token);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? (result['success'] == true ? 'Fabric deleted' : 'Error deleting fabric')),
                      backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AdminProvider>().admin?.token ?? context.watch<UserProvider>().user?.token;

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
          'Fabric Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_add_fabric_fab',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('ADD FABRIC', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<FabricProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allFabrics.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (provider.allFabrics.isEmpty) {
            return const Center(
              child: Text('No fabrics configured', style: TextStyle(color: AppColors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: provider.allFabrics.length,
            itemBuilder: (context, index) {
              final fabric = provider.allFabrics[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.15)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Text(
                        fabric.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: fabric.isActive
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: fabric.isActive ? Colors.green : Colors.red,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          fabric.isActive ? 'Active' : 'Disabled',
                          style: TextStyle(
                            color: fabric.isActive ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle Switch
                      Switch(
                        value: fabric.isActive,
                        activeThumbColor: AppColors.gold,
                        activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (val) async {
                          if (token == null) return;
                          final success = await provider.toggleFabricStatus(fabric.id, val, token);
                          if (mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${fabric.name} ${val ? "enabled" : "disabled"} for customers'),
                                backgroundColor: val ? Colors.green : Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      // Edit Name Button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                        onPressed: () => _showAddEditDialog(fabric: fabric),
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _confirmDelete(fabric),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
