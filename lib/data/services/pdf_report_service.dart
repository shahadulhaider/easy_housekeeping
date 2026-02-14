import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A single line item in a bazar report.
class ReportLineItem {
  final String name;
  final double quantity;
  final String unit;
  final double totalPrice;

  const ReportLineItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.totalPrice,
  });
}

/// Generates PDF reports for household spending summaries.
class PdfReportService {
  /// Generates a monthly bazar expenditure report as a PDF byte buffer.
  Future<Uint8List> generateMonthlyBazarReport({
    required String monthLabel,
    required double totalSpend,
    required List<ReportLineItem> items,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'EasyHousekeeping - Monthly Bazar Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Subtitle — month label
              pw.Text(monthLabel, style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),

              // Items table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                },
                headers: ['Item', 'Qty', 'Unit', 'Total (\u09F3)'],
                data: items
                    .map(
                      (item) => [
                        item.name,
                        item.quantity.toStringAsFixed(
                          item.quantity == item.quantity.roundToDouble()
                              ? 0
                              : 2,
                        ),
                        item.unit,
                        item.totalPrice.toStringAsFixed(2),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 16),

              // Grand total footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: \u09F3${totalSpend.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
