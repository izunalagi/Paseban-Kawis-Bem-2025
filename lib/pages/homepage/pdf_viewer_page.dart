import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../utils/constants.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  File? _pdfFile;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      String fullUrl = widget.pdfUrl;
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        fullUrl = 'https://pasebankawis.himatifunej.com/$fullUrl';
      }

      print('Loading PDF from: $fullUrl');

      // Download PDF
      final response = await http
          .get(
            Uri.parse(fullUrl),
            headers: {
              'Accept': 'application/pdf',
              'User-Agent': 'PasebanKawis/1.0',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - PDF tidak dapat diakses');
            },
          );

      print('Response status code: ${response.statusCode}');
      print('Response body length: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final contentLength = response.bodyBytes.length;

        print('Content-Type: $contentType');
        print('Content-Length: $contentLength bytes');

        // Validate PDF content
        if (contentType.contains('application/pdf') ||
            (contentLength > 4 &&
                response.bodyBytes.take(4).toList() ==
                    [0x25, 0x50, 0x44, 0x46])) {
          // Save PDF to temporary file
          final tempDir = await getTemporaryDirectory();
          final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${tempDir.path}/$fileName');

          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            _pdfFile = file;
            _isLoading = false;
          });

          print('PDF saved to: ${file.path}');
        } else {
          throw Exception(
            'File bukan PDF yang valid - Content-Type: $contentType',
          );
        }
      } else {
        throw Exception(
          'Failed to load PDF: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error loading PDF: $e');
      String errorMessage = 'Gagal memuat PDF';

      if (e.toString().contains('timeout')) {
        errorMessage = 'PDF tidak dapat diakses - cek koneksi internet';
      } else if (e.toString().contains('404')) {
        errorMessage = 'File PDF tidak ditemukan di server';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Tidak memiliki akses ke file PDF';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error - coba lagi nanti';
      } else if (e.toString().contains('PDF yang valid')) {
        errorMessage = 'File bukan PDF yang valid';
      }

      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = errorMessage;
      });

      _showErrorSnackbar(errorMessage);
    }
  }

  void _showErrorSnackbar(String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP, // muncul dari atas
      icon: const Icon(Icons.error, color: Colors.white),
    ).show(context);
  }

  Future<void> _downloadPdf() async {
    try {
      if (_pdfFile == null) {
        _showErrorSnackbar('PDF belum dimuat');
        return;
      }

      // Untuk sementara, buka PDF di aplikasi eksternal sebagai download
      String fullUrl = widget.pdfUrl;
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        fullUrl = 'https://pasebankawis.himatifunej.com/$fullUrl';
      }

      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Flushbar(
          message: 'PDF dibuka di aplikasi eksternal untuk di-download',
          backgroundColor: AppColors.info,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
          icon: const Icon(Icons.info, color: Colors.white),
        ).show(context);
      } else {
        Flushbar(
          message: 'Tidak dapat membuka PDF untuk download',
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.white),
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        message: 'Error download PDF: $e',
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      ).show(context);
    }
  }

  Widget _buildPdfViewer() {
    if (_pdfFile == null) {
      return _buildErrorView();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PDFView(
          filePath: _pdfFile!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false, // Tidak ada spacing otomatis
          pageFling: true,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.BOTH, // Menyesuaikan dengan frame halaman
          preventLinkNavigation: false,
          onRender: (pages) {
            print('PDF rendered with $pages pages');
            if (pages != null && pages > 1) {
              print('Multi-page PDF detected: $pages pages');
              Flushbar(
                message: 'PDF berhasil dimuat dengan $pages halaman',
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(8),
                flushbarPosition: FlushbarPosition.TOP,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              ).show(context);
            }
          },
          onError: (error) {
            print('PDF error: $error');
            setState(() {
              _hasError = true;
              _errorMessage = 'Error rendering PDF: $error';
            });
          },
          onPageError: (page, error) {
            print('Error on page $page: $error');
            // Try to recover from page errors
            if (_pdfViewController != null && page != null) {
              _pdfViewController!.setPage(page);
            }
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _pdfViewController = pdfViewController;
            print('PDF viewer created successfully');
          },
          onPageChanged: (page, total) {
            print('Page changed to $page of $total');
          },
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Gagal memuat PDF',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadPdf,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat PDF...',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF043461),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_pdfFile != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadPdf,
              tooltip: 'Download PDF',
            ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Info bar untuk PDF multi-halaman
          if (_pdfFile != null && !_isLoading && !_hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.infoLight.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Scroll ke bawah untuk melihat halaman lainnya',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // PDF content
          Expanded(child: _isLoading ? _buildLoadingView() : _buildPdfViewer()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewController?.dispose();
    super.dispose();
  }
}
