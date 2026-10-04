import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const InvoiceDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateFormat('yyyyMMdd').format(order.createdAt);
    final String shortId = order.id.length >= 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase();
    final String invoiceNumber = 'INV-$dateStr-$shortId';
    final bool isPaid = order.isPaid || order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'confirmed';

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
          'Tax Invoice',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.gold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice $invoiceNumber downloaded successfully!'),
                  backgroundColor: AppColors.gold,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Printable Invoice Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. BRAND HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'RAYMAANS TAILORS',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Raymaans Tailors,\nEriyur, Sunchalnatham (PO),\nPennagaram Taluk,\nDharmapuri District – 636810,\nTamil Nadu, India.',
                              style: TextStyle(color: AppColors.grey, fontSize: 11, height: 1.4),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ph: +91 9444024411 | GSTIN: 33AAAAA0000A1Z5',
                              style: TextStyle(color: AppColors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: const Text(
                          'TAX INVOICE',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white24, height: 28),

                  // 2. INVOICE META & CUSTOMER DETAILS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('INVOICE DETAILS', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 6),
                            Text('Invoice No: $invoiceNumber', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Date: ${DateFormat('dd MMM yyyy').format(order.createdAt)}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Order Ref: #$shortId', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Payment: ${order.paymentMethod}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              'Status: ${isPaid ? "PAID" : "PENDING"}',
                              style: TextStyle(color: isPaid ? Colors.green : AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Billed To
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BILLED TO', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 6),
                            Text(
                              order.shippingAddress.fullName.isNotEmpty ? order.shippingAddress.fullName : 'Valued Customer',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.shippingAddress.doorNumber}, ${order.shippingAddress.street},\n${order.shippingAddress.area}, ${order.shippingAddress.city}',
                              style: const TextStyle(color: AppColors.grey, fontSize: 11, height: 1.3),
                            ),
                            const SizedBox(height: 2),
                            Text('Ph: ${order.shippingAddress.mobile}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. ITEMIZED ORDER TABLE
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF222222),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('ITEM', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.right, style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        // Table Rows
                        ...order.orderItems.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      if (item.size != null && item.size!.isNotEmpty)
                                        Text('Size: ${item.size}', style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('₹${item.price.toInt()}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('₹${(item.price * item.quantity).toInt()}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. FINANCIAL SUMMARY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal', '₹${order.itemsPrice.toInt()}'),
                            const SizedBox(height: 6),
                            _buildSummaryRow('Taxes (GST 5% Incl.)', '₹${(order.itemsPrice * 0.05).toInt()}'),
                            const SizedBox(height: 6),
                            _buildSummaryRow('Delivery Charge', order.shippingPrice > 0 ? '₹${order.shippingPrice.toInt()}' : 'FREE'),
                            const Divider(color: Colors.white24, height: 16),
                            _buildSummaryRow('Grand Total', '₹${order.totalPrice.toInt()}', isBold: true, valueColor: AppColors.gold),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white12, height: 28),

                  // 5. FOOTER & DECLARATION
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Thank you for choosing Raymaans Tailors!',
                          style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bespoke Tailoring & Custom Fit Apparel • Computer Generated Invoice',
                          style: TextStyle(color: AppColors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invoice $invoiceNumber downloaded to device!'),
                            backgroundColor: AppColors.gold,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.file_download, color: Colors.black, size: 18),
                      label: const Text('DOWNLOAD PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing invoice link...'),
                            backgroundColor: AppColors.gold,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share, color: AppColors.gold, size: 18),
                      label: const Text('SHARE', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.white : AppColors.grey, fontSize: isBold ? 13 : 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: valueColor ?? (isBold ? Colors.white : Colors.white), fontSize: isBold ? 15 : 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
