import 'package:flutter/material.dart';
import '../../services/quiz_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'quiz_detail_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List<dynamic> _allQuizzes = [];
  List<dynamic> _filteredQuizzes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final quizService = QuizService();
      final quizData = await quizService.fetchQuizList();

      if (mounted) {
        setState(() {
          _allQuizzes = quizData ?? [];
          _filteredQuizzes = List.from(_allQuizzes);
          _isLoading = false;
        });
        print('Loaded ${_allQuizzes.length} quizzes');
        // Debug: print first quiz structure
        if (_allQuizzes.isNotEmpty) {
          print('First quiz data: ${_allQuizzes[0]}');
        }
      }
    } catch (e) {
      print('Error loading quizzes: $e');
      if (mounted) {
        setState(() {
          _allQuizzes = [];
          _filteredQuizzes = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar kuis: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadQuizzes,
            ),
          ),
        );
      }
    }
  }

  void _filterQuizzes(String query) {
    if (!mounted) return;

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredQuizzes = List.from(_allQuizzes);
      } else {
        _filteredQuizzes = _allQuizzes.where((quiz) {
          // Coba berbagai kemungkinan field name
          final title = (quiz['title'] ?? quiz['judul'] ?? quiz['nama'] ?? '')
              .toString()
              .toLowerCase();
          final description =
              (quiz['description'] ?? quiz['deskripsi'] ?? quiz['desc'] ?? '')
                  .toString()
                  .toLowerCase();
          final category = (quiz['category'] ?? quiz['kategori'] ?? '')
              .toString()
              .toLowerCase();
          final queryLower = query.toLowerCase();

          return title.contains(queryLower) ||
              description.contains(queryLower) ||
              category.contains(queryLower);
        }).toList();
      }
    });

    print('Search query: $query, Found: ${_filteredQuizzes.length} results');
  }

  Future<void> _refreshQuizzes() async {
    await _loadQuizzes();
  }

  void _navigateToQuizDetail(dynamic quiz) {
    if (!mounted || quiz == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizDetailPage(quiz: quiz)),
    ).catchError((error) {
      print('Navigation error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka detail kuis'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Daftar Kuis', showBackButton: true),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat daftar kuis...')
          : Column(
              children: [
                // Search Bar - Only show when not loading
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterQuizzes,
                    decoration: InputDecoration(
                      hintText: 'Cari kuis...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterQuizzes('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Quiz List
                Expanded(child: _buildQuizList()),
              ],
            ),
    );
  }

  Widget _buildQuizList() {
    // Remove the loading check here since it's handled in main build method
    if (_allQuizzes.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    if (_filteredQuizzes.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoSearchResults();
    }

    return RefreshIndicator(
      onRefresh: _refreshQuizzes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = _filteredQuizzes[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kuis tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan hubungi admin untuk menambahkan kuis',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadQuizzes,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kuis yang sesuai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian: "$_searchQuery"',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _filterQuizzes('');
            },
            child: const Text('Hapus Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(dynamic quiz) {
    if (quiz == null) return const SizedBox.shrink();

    // Debug: print quiz data structure
    print('Quiz card data: $quiz');

    // Coba berbagai kemungkinan field name untuk title
    final title =
        quiz['title']?.toString() ??
        quiz['judul']?.toString() ??
        quiz['nama']?.toString() ??
        'Judul Tidak Tersedia';

    // Coba berbagai kemungkinan field name untuk description
    final description =
        quiz['description']?.toString() ??
        quiz['deskripsi']?.toString() ??
        quiz['desc']?.toString() ??
        '';

    // Coba berbagai kemungkinan field name untuk category
    final category =
        quiz['category']?.toString() ?? quiz['kategori']?.toString() ?? 'Umum';

    // Coba berbagai kemungkinan field name untuk thumbnail
    final thumbnail =
        quiz['thumbnail']?.toString() ??
        quiz['image']?.toString() ??
        quiz['foto']?.toString() ??
        '';

    final duration =
        quiz['durasi']?.toString() ?? quiz['duration']?.toString() ?? '';

    String imageUrl = '';
    if (thumbnail.isNotEmpty) {
      if (thumbnail.startsWith('http')) {
        imageUrl = thumbnail;
      } else {
        imageUrl = 'https://pasebankawis.himatifunej.com/$thumbnail';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _navigateToQuizDetail(quiz),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Quiz Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.accent.withOpacity(0.1),
                                child: Icon(
                                  Icons.quiz,
                                  size: 30,
                                  color: AppColors.accent,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.accent.withOpacity(0.1),
                            child: Icon(
                              Icons.quiz,
                              size: 30,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Quiz Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildInfoChip(
                            Icons.category,
                            category,
                            Colors.blue[600]!,
                          ),
                          if (duration.isNotEmpty)
                            _buildInfoChip(
                              Icons.timer,
                              '$duration menit',
                              Colors.orange[600]!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
