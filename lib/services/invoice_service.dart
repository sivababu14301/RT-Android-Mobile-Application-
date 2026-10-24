import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';

class InvoiceService {
  static final PdfColor _gold = PdfColor.fromHex('#D4AF37');
  static final PdfColor _black = PdfColor.fromHex('#000000');
  static final PdfColor _darkCard = PdfColor.fromHex('#111111');
  static final PdfColor _lightGrey = PdfColor.fromHex('#E0E0E0');
  static final PdfColor _greyText = PdfColor.fromHex('#777777');

  /// Generates a PDF invoice document for the given order and saves it to storage
  static Future<File> generateInvoicePdf(OrderModel order) async {
    final pdf = pw.Document(
      title: 'Invoice_INV-${order.id.length > 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase()}',
      author: 'RT - Raymaans Tailors',
    );

    final String shortId = order.id.length > 6
        ? order.id.substring(order.id.length - 6).toUpperCase()
        : order.id.toUpperCase();
    final String invoiceNo = 'INV-$shortId';
    final String dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    // Build PDF Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Row: Brand & Title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RT - RAYMAANS TAILORS',
                        style: pw.TextStyle(
                          color: _black,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Bespoke Tailoring & Formal Suiting Specialist',
                        style: pw.TextStyle(color: _greyText, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: _darkCard,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: _gold, thickness: 1.5),
              pw.SizedBox(height: 16),

              // Metadata Block: Customer Info & Invoice Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Billed To Column
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO:',
                          style: pw.TextStyle(
                            color: _gold,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          order.shippingAddress.fullName,
                          style: pw.TextStyle(
                            color: _black,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${order.shippingAddress.doorNumber}, ${order.shippingAddress.street}',
                          style: pw.TextStyle(color: _black, fontSize: 10),
                        ),
                        pw.Text(
                          '${order.shippingAddress.area}, ${order.shippingAddress.city}',
                          style: pw.TextStyle(color: _black, fontSize: 10),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: ${order.shippingAddress.mobile}',
                          style: pw.TextStyle(color: _black, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  // Invoice Meta Column
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE DETAILS:',
                          style: pw.TextStyle(
                            color: _gold,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _buildPdfMetaRow('Invoice No:', invoiceNo),
                        _buildPdfMetaRow('Order ID:', '#$shortId'),
                        _buildPdfMetaRow('Date:', dateStr),
                        _buildPdfMetaRow('Payment Method:', order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Cash on Delivery'),
                        _buildPdfMetaRow('Payment Status:', order.isPaid ? 'PAID' : 'PENDING', isHighlight: true),
                        _buildPdfMetaRow('Order Status:', order.status),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Itemized Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _darkCard,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Text('#', style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 5, child: pw.Text('PRODUCT DESCRIPTION', style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('SIZE / COLOR', style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('UNIT PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('AMOUNT', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: _gold, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Table Body
              ...List.generate(order.orderItems.length, (idx) {
                final item = order.orderItems[idx];
                final double lineTotal = item.price * item.quantity;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: _lightGrey, width: 0.5)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 1, child: pw.Text('${idx + 1}', style: pw.TextStyle(fontSize: 10, color: _black))),
                      pw.Expanded(flex: 5, child: pw.Text(item.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _black))),
                      pw.Expanded(flex: 2, child: pw.Text('${item.size ?? "N/A"} / ${item.color ?? "N/A"}', style: pw.TextStyle(fontSize: 9, color: _black))),
                      pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, color: _black))),
                      pw.Expanded(flex: 2, child: pw.Text('INR ${item.price.toInt()}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, color: _black))),
                      pw.Expanded(flex: 2, child: pw.Text('INR ${lineTotal.toInt()}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _black))),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),

              // Summary Totals Box
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _darkCard,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfSummaryRow('Subtotal', 'INR ${order.itemsPrice.toInt()}', isGold: false),
                        _buildPdfSummaryRow('Shipping / Delivery', order.shippingPrice == 0 ? 'FREE' : 'INR ${order.shippingPrice.toInt()}', isGold: false),
                        pw.Divider(color: _gold, thickness: 0.8),
                        _buildPdfSummaryRow('TOTAL PAID', 'INR ${order.totalPrice.toInt()}', isGold: true),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Thank You Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _gold, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'THANK YOU FOR CHOOSING RT - RAYMAANS TAILORS!',
                      style: pw.TextStyle(
                        color: _black,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'We craft perfection for your custom tailored fits. For queries, contact support@raymaanstrailors.com',
                      style: pw.TextStyle(color: _greyText, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save File
    final String fileName = 'Invoice_$invoiceNo.pdf';
    Directory? storageDir;

    if (Platform.isAndroid) {
      storageDir = await getExternalStorageDirectory();
    } else {
      storageDir = await getApplicationDocumentsDirectory();
    }

    final File file = File('${storageDir!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildPdfMetaRow(String label, String value, {bool isHighlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _greyText)),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: isHighlight ? _gold : _black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfSummaryRow(String label, String value, {required bool isGold}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: isGold ? _gold : PdfColors.white,
              fontSize: isGold ? 11 : 9,
              fontWeight: isGold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: isGold ? _gold : PdfColors.white,
              fontSize: isGold ? 12 : 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the PDF file using system default PDF viewer
  static Future<void> openPdf(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      // Fallback preview print
      final File f = File(filePath);
      if (await f.exists()) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await f.readAsBytes(),
        );
      }
    }
  }

  /// Shares the PDF file via Printing share sheet
  static Future<void> sharePdf(String filePath, String fileName) async {
    final File f = File(filePath);
    if (await f.exists()) {
      await Printing.sharePdf(
        bytes: await f.readAsBytes(),
        filename: fileName,
      );
    }
  }
}
