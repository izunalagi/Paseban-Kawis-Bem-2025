import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/modul_model.dart';
import 'pdf_viewer_page.dart';

class ModulDetailPage extends StatefulWidget {
  final ModulModel modul;

  const ModulDetailPage({super.key, required this.modul});

  @override
  State<ModulDetailPage> createState() => _ModulDetailPageState();
}

class _ModulDetailPageState extends State<ModulDetailPage>
    with WidgetsBindingObserver {
  WebViewController? _webViewController;
  bool _isVideoAvailable = false;
  bool _showWebView = false;
  bool _isLoading = false;
  String _videoId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _videoId = _extractYouTubeVideoId(widget.modul.linkVideo);
    _isVideoAvailable = _videoId.isNotEmpty;
  }

  @override
  void didChangeMetrics() {
    // Handle metrics changes safely
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle
  }

  String _extractYouTubeVideoId(String url) {
    if (url.isEmpty) return '';
    url = url.trim();

    final patterns = [
      RegExp(
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
      ),
      RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    return '';
  }

  void _initializeWebView() {
    if (!_isVideoAvailable) return;

    setState(() {
      _isLoading = true;
      _showWebView = true;
    });

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://www.youtube.com/embed/$_videoId?autoplay=0&rel=0&modestbranding=1',
        ),
      );
  }

  Future<void> _launchVideoInExternalApp() async {
    if (!_isVideoAvailable) {
      _showErrorSnackbar('Link video tidak tersedia');
      return;
    }

    try {
      final url = 'https://www.youtube.com/watch?v=$_videoId';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('Tidak dapat membuka YouTube');
      }
    } catch (e) {
      print('Error launching external video: $e');
      _showErrorSnackbar('Tidak dapat membuka video');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _launchPdf() async {
    if (widget.modul.pathPdf == null || widget.modul.pathPdf!.isEmpty) {
      _showErrorSnackbar('File PDF tidak tersedia');
      return;
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfUrl: widget.modul.pathPdf!,
            title: widget.modul.judulModul,
          ),
        ),
      );
    } catch (e) {
      print('Error launching PDF: $e');
      _showErrorSnackbar('Tidak dapat membuka file PDF');
    }
  }

  void _toggleVideoPlayback() {
    if (_showWebView && _webViewController != null) {
      // Try to control playback via JavaScript
      _webViewController!.runJavaScript('''
        var video = document.querySelector('video');
        if (video) {
          if (video.paused) {
            video.play();
          } else {
            video.pause();
          }
        }
      ''');
    } else if (_isVideoAvailable) {
      _initializeWebView();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (!_isVideoAvailable) {
      return _buildNoVideoView();
    }

    if (_showWebView && _webViewController != null) {
      return _buildWebVideoPlayer();
    }

    return _buildVideoThumbnail();
  }

  Widget _buildWebVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade900],
              ),
            ),
          ),

          // Thumbnail image
          if (_isVideoAvailable)
            Positioned.fill(
              child: Image.network(
                'https://img.youtube.com/vi/$_videoId/maxresdefault.jpg',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.red.shade800,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://img.youtube.com/vi/$_videoId/hqdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.red.shade800),
                  );
                },
              ),
            ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),

          // Play button
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),

          // Text overlay
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tonton Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Klik untuk memutar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Touch overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_isVideoAvailable) {
                    _initializeWebView();
                  }
                },
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVideoView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.grey, size: 48),
              SizedBox(height: 12),
              Text(
                'Video Tidak Tersedia',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: widget.modul.judulModul,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Video Section
          _buildVideoSection(),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isVideoAvailable
                        ? _launchVideoInExternalApp
                        : null,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text(
                      'Buka di YouTube',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isVideoAvailable
                          ? Colors.red
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isVideoAvailable ? _toggleVideoPlayback : null,
                    icon: Icon(
                      _showWebView ? Icons.refresh : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(
                      _showWebView ? 'Refresh' : 'Putar',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isVideoAvailable
                          ? Colors.blue
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Materi Modul',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPdfSection(),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi Modul',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Modul',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfSection() {
    if (widget.modul.pathPdf != null && widget.modul.pathPdf!.isNotEmpty) {
      return GestureDetector(
        onTap: _launchPdf,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modul ${widget.modul.judulModul}.pdf',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Klik untuk membuka materi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 24),
            SizedBox(width: 12),
            Text(
              'Materi PDF belum tersedia',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.modul.deskripsiModul.isNotEmpty
            ? widget.modul.deskripsiModul
            : 'Deskripsi modul belum tersedia.',
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Kategori',
            widget.modul.namaKategori ?? 'Tidak ada kategori',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Tanggal Dibuat',
            widget.modul.createdAt != null
                ? '${widget.modul.createdAt!.day}/${widget.modul.createdAt!.month}/${widget.modul.createdAt!.year}'
                : 'Tidak tersedia',
          ),
          if (widget.modul.updatedAt != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              'Terakhir Diupdate',
              '${widget.modul.updatedAt!.day}/${widget.modul.updatedAt!.month}/${widget.modul.updatedAt!.year}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
