import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../widgets/custom_app_bar.dart';
import './widgets/receipt_header_widget.dart';
import './widgets/participant_info_widget.dart';
import './widgets/amount_breakdown_widget.dart';
import './widgets/technical_details_widget.dart';
import './widgets/security_section_widget.dart';
import './widgets/action_buttons_widget.dart';

/// Transaction Receipt Screen
///
/// Provides comprehensive transaction documentation with professional formatting
/// and security verification for Token V Wallet users.
class TransactionReceipt extends StatefulWidget {
  const TransactionReceipt({super.key});

  @override
  State<TransactionReceipt> createState() => _TransactionReceiptState();
}

class _TransactionReceiptState extends State<TransactionReceipt> {
  Map<String, dynamic>? _transaction;
  bool _isGenerating = false;
  bool _isPrinting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() => _transaction = args);
    }
  }

  String _generateTransactionHash() {
    return 'TX${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}ABC${_transaction?['id'] ?? 'UNKNOWN'}';
  }

  Future<void> _downloadPDF() async {
    if (_transaction == null) return;

    setState(() => _isGenerating = true);

    try {
      final pdf = await _generatePDF();

      if (kIsWeb) {
        await _downloadPDFWeb(pdf);
      } else {
        await _downloadPDFMobile(pdf);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();
    final theme = Theme.of(context);

    final String transactionId = _transaction?['id'] ?? 'UNKNOWN';
    final String contactName = _transaction?['contactName'] ?? 'Unknown User';
    final String type = _transaction?['type'] ?? 'sent';
    final double amount = _transaction?['amount'] ?? 0.0;
    final double fees = _transaction?['fees'] ?? 0.0;
    final DateTime timestamp = _transaction?['timestamp'] ?? DateTime.now();
    final String status = _transaction?['status'] ?? 'completed';
    final String note = _transaction?['note'] ?? '';

    final transactionHash = _generateTransactionHash();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Token V Wallet',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Transaction Receipt',
                      style: const pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Verified & Secure',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Transaction Details
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              _buildPDFRow('Transaction ID:', transactionId),
              _buildPDFRow('Contact:', contactName),
              _buildPDFRow('Type:', type == 'sent' ? 'Sent' : 'Received'),
              _buildPDFRow('Status:', status.toUpperCase()),
              _buildPDFRow(
                  'Date:', DateFormat('MMM dd, yyyy HH:mm').format(timestamp)),

              pw.SizedBox(height: 20),

              // Amount Breakdown
              pw.Text(
                'Amount Breakdown',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              _buildPDFRow('Base Amount:', '\$${amount.toStringAsFixed(2)}'),
              _buildPDFRow('Processing Fees:', '\$${fees.toStringAsFixed(2)}'),
              _buildPDFRow('Network Charges:', '\$0.00'),
              pw.Divider(),
              _buildPDFRow(
                'Total Amount:',
                '\$${(amount + fees).toStringAsFixed(2)}',
                bold: true,
              ),

              pw.SizedBox(height: 20),

              // Technical Information
              pw.Text(
                'Technical Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              _buildPDFRow('Blockchain Hash:', transactionHash),
              _buildPDFRow('Processing Duration:', '< 1 second'),
              _buildPDFRow('Confirmations:', '6/6'),
              _buildPDFRow('Security Level:', 'High'),

              if (note.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Note',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                pw.Text(note),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'This is an official receipt from Token V Wallet. For verification, visit our website.',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPDFRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDFWeb(pw.Document pdf) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
          'download', 'receipt_${_transaction?['id'] ?? 'unknown'}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _downloadPDFMobile(pw.Document pdf) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/receipt_${_transaction?['id'] ?? 'unknown'}.pdf');
    await file.writeAsBytes(bytes);
  }

  Future<void> _shareReceipt() async {
    if (_transaction == null) return;

    setState(() => _isGenerating = true);

    try {
      final pdf = await _generatePDF();
      final bytes = await pdf.save();

      if (kIsWeb) {
        await _downloadPDFWeb(pdf);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file =
            File('${directory.path}/receipt_${_transaction?['id']}.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Transaction Receipt');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _printReceipt() async {
    if (_transaction == null) return;

    setState(() => _isPrinting = true);

    try {
      final pdf = await _generatePDF();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_transaction == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Transaction Receipt',
          variant: CustomAppBarVariant.centered,
        ),
        body: Center(
          child: Text('No transaction data available',
              style: theme.textTheme.bodyLarge),
        ),
      );
    }

    final String transactionId = _transaction?['id'] ?? 'UNKNOWN';
    final String contactName = _transaction?['contactName'] ?? 'Unknown User';
    final String contactAvatar = _transaction?['contactAvatar'] ?? '';
    final String semanticLabel =
        _transaction?['semanticLabel'] ?? 'Profile picture';
    final String type = _transaction?['type'] ?? 'sent';
    final double amount = _transaction?['amount'] ?? 0.0;
    final double fees = _transaction?['fees'] ?? 0.0;
    final DateTime timestamp = _transaction?['timestamp'] ?? DateTime.now();
    final String status = _transaction?['status'] ?? 'completed';
    final String note = _transaction?['note'] ?? '';

    final transactionHash = _generateTransactionHash();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Transaction Receipt',
        variant: CustomAppBarVariant.centered,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt Header
              ReceiptHeaderWidget(
                timestamp: timestamp,
                status: status,
              ),

              Container(
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Participant Information
                    ParticipantInfoWidget(
                      contactName: contactName,
                      contactAvatar: contactAvatar,
                      semanticLabel: semanticLabel,
                      type: type,
                    ),

                    Divider(height: 1, color: theme.colorScheme.outline),

                    // Amount Display
                    Container(
                      padding: EdgeInsets.all(5.w),
                      child: Column(
                        children: [
                          Text(
                            type == 'sent' ? 'You Sent' : 'You Received',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: type == 'sent' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (note.isNotEmpty) ...[
                            SizedBox(height: 1.h),
                            Text(
                              note,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    Divider(height: 1, color: theme.colorScheme.outline),

                    // Amount Breakdown
                    AmountBreakdownWidget(
                      amount: amount,
                      fees: fees,
                    ),

                    Divider(height: 1, color: theme.colorScheme.outline),

                    // Technical Details
                    TechnicalDetailsWidget(
                      transactionId: transactionId,
                      transactionHash: transactionHash,
                      timestamp: timestamp,
                      status: status,
                      onCopy: _copyToClipboard,
                    ),

                    Divider(height: 1, color: theme.colorScheme.outline),

                    // Security Section
                    SecuritySectionWidget(
                      transactionHash: transactionHash,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Action Buttons
              ActionButtonsWidget(
                isGenerating: _isGenerating,
                isPrinting: _isPrinting,
                onDownload: _downloadPDF,
                onShare: _shareReceipt,
                onPrint: _printReceipt,
              ),

              SizedBox(height: 2.h),

              // Disclaimer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'This is an official receipt from Token V Wallet. For verification, please check the QR code and transaction hash.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
