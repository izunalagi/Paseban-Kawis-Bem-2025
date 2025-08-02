import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'quiz_detail_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List<dynamic> filteredQuizzes = [];
  String searchQuery = '';
  Map<int, int> quizQuestionCounts = {};

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchQuizList();
    _filterQuizzes();
    _loadQuestionCounts();
  }

  void _filterQuizzes() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final allQuizzes = quizProvider.quizList;

    if (searchQuery.isEmpty) {
      setState(() {
        filteredQuizzes = List.from(allQuizzes);
      });
    } else {
      setState(() {
        filteredQuizzes = allQuizzes.where((quiz) {
          final title = quiz['judul']?.toString().toLowerCase() ?? '';
          final category = quiz['kategori']?.toString().toLowerCase() ?? '';
          final description = quiz['deskripsi']?.toString().toLowerCase() ?? '';
          final query = searchQuery.toLowerCase();

          return title.contains(query) ||
              category.contains(query) ||
              description.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadQuestionCounts() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    for (var quiz in filteredQuizzes) {
      try {
        await quizProvider.fetchQuizDetail(quiz['id']);
        setState(() {
          quizQuestionCounts[quiz['id']] =
              quizProvider.quizDetail?['total_questions'] ?? 0;
        });
      } catch (e) {
        // If failed to load question count, set to 0
        setState(() {
          quizQuestionCounts[quiz['id']] = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(title: 'Daftar Kuis', showBackButton: true),
          body: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: CustomSearchBar(
                  hintText: 'Cari kuis...',
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _filterQuizzes();
                  },
                ),
              ),

              // Quiz List
              Expanded(
                child: quizProvider.isLoading
                    ? LoadingWidget()
                    : filteredQuizzes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadQuizzes,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredQuizzes.length,
                          itemBuilder: (context, index) {
                            return _buildQuizCard(filteredQuizzes[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.quiz_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'Belum ada kuis tersedia'
                : 'Tidak ada kuis yang sesuai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Silakan hubungi admin untuk menambahkan kuis'
                : 'Coba ubah kata kunci pencarian Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(dynamic quiz) {
    final questionCount = quizQuestionCounts[quiz['id']] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: Provider.of<QuizProvider>(context, listen: false),
                  child: QuizDetailPage(quiz: quiz),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
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
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      quiz['thumbnail'].startsWith('http')
                          ? quiz['thumbnail']
                          : 'http://10.42.223.86:8000/${quiz['thumbnail']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Quiz Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['judul'] ?? 'Judul Kuis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (quiz['deskripsi'] != null &&
                          quiz['deskripsi'].isNotEmpty)
                        Text(
                          quiz['deskripsi'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.quiz,
                            '$questionCount soal',
                            AppColors.accent,
                          ),
                          SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.category,
                            quiz['kategori'] ?? 'Umum',
                            Colors.blue[600]!,
                          ),
                          if (quiz['durasi'] != null) ...[
                            SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.timer,
                              '${quiz['durasi']} menit',
                              Colors.orange[600]!,
                            ),
                          ],
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
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
