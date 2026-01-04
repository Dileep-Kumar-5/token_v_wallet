import 'package:file_picker/file_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

import '../../../services/payment_service.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String bankAccountId;
  final VoidCallback onDocumentsUploaded;

  const DocumentUploadWidget({
    Key? key,
    required this.bankAccountId,
    required this.onDocumentsUploaded,
  }) : super(key: key);

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final PaymentService _paymentService = PaymentService();
  final List<Map<String, dynamic>> _uploadedDocs = [];
  bool _isUploading = false;

  Future<void> _pickDocument(String documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() => _isUploading = true);

        final file = result.files.first;

        // In production, upload to Supabase Storage
        final filePath = 'documents/${widget.bankAccountId}/${file.name}';

        await _paymentService.uploadVerificationDocument(
          bankAccountId: widget.bankAccountId,
          documentType: documentType,
          filePath: filePath,
          fileName: file.name,
          fileSize: file.size,
          mimeType: file.extension ?? 'application/octet-stream',
        );

        setState(() {
          _uploadedDocs.add({
            'type': documentType,
            'name': file.name,
            'size': file.size,
          });
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document uploaded successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Verification Documents',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please upload the following documents for verification',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 3.h),

          // Document Type Options
          _buildDocumentTypeCard(
            'Bank Statement',
            'bank_statement',
            'Recent bank statement (last 3 months)',
            Icons.description,
          ),
          SizedBox(height: 2.h),

          _buildDocumentTypeCard(
            'Void Check',
            'void_check',
            'Cancelled check or deposit slip',
            Icons.check_circle_outline,
          ),
          SizedBox(height: 2.h),

          _buildDocumentTypeCard(
            'Government ID',
            'government_id',
            'Valid government-issued ID',
            Icons.badge,
          ),
          SizedBox(height: 3.h),

          // Uploaded Documents List
          if (_uploadedDocs.isNotEmpty) ...[
            Text(
              'Uploaded Documents',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _uploadedDocs.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final doc = _uploadedDocs[index];
                return Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(doc['size'] / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
          ],

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _uploadedDocs.isEmpty || _isUploading
                  ? null
                  : widget.onDocumentsUploaded,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text('Continue to Verification'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeCard(
    String title,
    String type,
    String description,
    IconData icon,
  ) {
    final isUploaded = _uploadedDocs.any((doc) => doc['type'] == type);

    return InkWell(
      onTap: _isUploading ? null : () => _pickDocument(type),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isUploaded ? Colors.green[300]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green[100] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : icon,
                color: isUploaded ? Colors.green[700] : Colors.blue[700],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.done : Icons.upload_file,
              color: isUploaded ? Colors.green[700] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
