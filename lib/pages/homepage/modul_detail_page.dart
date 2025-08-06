import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _ModulDetailPageState extends State<ModulDetailPage> {
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;
  bool _hasError = false;
  bool _isFullScreen = false; // Tambahkan state untuk fullscreen
  String _videoId = '';

  @override
  void initState() {
    super.initState();
    _videoId = _extractYouTubeVideoId(widget.modul.linkVideo);

    if (_videoId.isNotEmpty) {
      _initializeYouTubePlayer();
    }
  }

  String _extractYouTubeVideoId(String url) {
    if (url.isEmpty) return '';

    url = url.trim();

    // Regex patterns untuk berbagai format YouTube URL
    final patterns = [
      RegExp(
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
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

  void _initializeYouTubePlayer() {
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
          captionLanguage: 'id',
          startAt: 0,
          hideControls: false,
          controlsVisibleAtStart: true,
          disableDragSeek: false,
          useHybridComposition: false,
        ),
      );

      // Add listeners
      _youtubeController!.addListener(() {
        // Player ready
        if (_youtubeController!.value.isReady && !_isPlayerReady) {
          setState(() {
            _isPlayerReady = true;
            _hasError = false;
          });
        }

        // Handle errors
        if (_youtubeController!.value.hasError) {
          setState(() {
            _hasError = true;
          });
        }

        // Handle fullscreen changes
        if (_youtubeController!.value.isFullScreen != _isFullScreen) {
          setState(() {
            _isFullScreen = _youtubeController!.value.isFullScreen;
          });

          if (_isFullScreen) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          }
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _launchVideoInExternalApp() async {
    if (widget.modul.linkVideo.isEmpty && _videoId.isEmpty) {
      _showErrorSnackbar('Link video tidak tersedia');
      return;
    }

    try {
      String finalUrl = widget.modul.linkVideo;

      if (_videoId.isNotEmpty) {
        finalUrl = 'https://www.youtube.com/watch?v=$_videoId';
      }

      final uri = Uri.parse(finalUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfUrl: widget.modul.pathPdf!,
            title: widget.modul.judulModul,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Tidak dapat membuka file PDF');
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    // Restore system UI dan orientation ketika dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
    if (_videoId.isEmpty) {
      return _buildFallbackView();
    }

    if (_youtubeController != null && _isPlayerReady) {
      return _buildYouTubePlayer();
    }

    return _buildThumbnailView();
  }

  Widget _buildYouTubePlayer() {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Restore system UI saat exit fullscreen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _youtubeController!.metadata.title,
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          const SizedBox(width: 10.0),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 10.0),
          RemainingDuration(),
          _buildQualityButton(),
          FullScreenButton(),
        ],
        onReady: () {},
        onEnded: (data) {},
      ),
      builder: (context, player) {
        return player;
      },
    );
  }

  Widget _buildQualityButton() {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () {
        _showQualityMenu();
      },
    );
  }

  void _showQualityMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Pilih Kualitas Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildQualityOption('Auto', 'Otomatis'),
                          _buildQualityOption('1080p', 'HD'),
                          _buildQualityOption('720p', 'HD'),
                          _buildQualityOption('480p', 'SD'),
                          _buildQualityOption('360p', 'SD'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityOption(String quality, String label) {
    return ListTile(
      leading: const Icon(Icons.video_settings, color: Colors.white),
      title: Text(
        quality,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(label, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        Navigator.pop(context);
        _setVideoQuality(quality);
      },
    );
  }

  void _setVideoQuality(String quality) {
    try {
      if (_youtubeController != null && _youtubeController!.value.isReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kualitas akan diatur otomatis oleh YouTube'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player belum siap'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengatur kualitas'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildThumbnailView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade700, Colors.red.shade900],
              ),
            ),
          ),
          if (_videoId.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                'https://img.youtube.com/vi/$_videoId/maxresdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://img.youtube.com/vi/$_videoId/hqdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.red.shade700, Colors.red.shade900],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
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
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
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
                const SizedBox(height: 4),
                const Text(
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
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_youtubeController != null) {
                    setState(() {
                      _isPlayerReady = true;
                    });
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

  Widget _buildFallbackView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade700, Colors.red.shade900],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_library,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Video Tidak Tersedia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Klik untuk membuka di YouTube',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _launchVideoInExternalApp,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Buka di YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _launchVideoInExternalApp,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Jika dalam mode fullscreen, tampilkan hanya video player
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: YoutubePlayerBuilder(
          onExitFullScreen: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          },
          player: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            bottomActions: [
              CurrentPosition(),
              const SizedBox(width: 10.0),
              ProgressBar(isExpanded: true),
              const SizedBox(width: 10.0),
              RemainingDuration(),
              FullScreenButton(),
            ],
            onReady: () {},
            onEnded: (data) {},
          ),
          builder: (context, player) {
            return Center(child: player);
          },
        ),
      );
    }

    // Layout normal
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
          if (widget.modul.linkVideo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _launchVideoInExternalApp,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text(
                        'Buka di YouTube',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
                      onPressed: () {
                        if (_youtubeController != null) {
                          if (_youtubeController!.value.isPlaying) {
                            _youtubeController!.pause();
                          } else {
                            _youtubeController!.play();
                          }
                        }
                      },
                      icon: Icon(
                        (_youtubeController?.value.isPlaying ?? false)
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(
                        (_youtubeController?.value.isPlaying ?? false)
                            ? 'Pause'
                            : 'Putar',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Materi Modul Section
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

                  // Deskripsi Modul
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

                  // Informasi Modul
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
