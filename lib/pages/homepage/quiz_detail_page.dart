import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import 'quiz_question_page.dart';
import 'quiz_review_page.dart';

class QuizDetailPage extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizDetailPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadQuizDetail();
    // Fetch user quiz scores to check if user has completed this quiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.fetchUserQuizScores();
    });
  }

  Future<void> _loadQuizDetail() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchQuizDetail(widget.quiz['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final quizDetail = quizProvider.quizDetail;
        final isLoading = quizProvider.isLoadingQuizDetail;
        final questionCount = quizDetail?['total_questions'] ?? 0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(title: 'Detail Kuis', showBackButton: true),
          body: isLoading
              ? LoadingWidget()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz Thumbnail
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            quizDetail?['thumbnail']?.startsWith('http') ??
                                    false
                                ? quizDetail!['thumbnail']
                                : 'http://10.42.223.86:8000/${quizDetail?['thumbnail'] ?? widget.quiz['thumbnail']}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Quiz Title
                      Text(
                        quizDetail?['title'] ??
                            widget.quiz['title'] ??
                            'Judul Kuis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Show user's score if completed
                      if (_hasCompletedQuiz(quizProvider))
                        _buildUserScoreCard(quizProvider),

                      // Quiz Description
                      if (quizDetail?['description'] != null &&
                          quizDetail?['description'].isNotEmpty == true)
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withOpacity(0.05),
                                Colors.purple.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Deskripsi Kuis',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  quizDetail?['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 24),

                      // Quiz Information Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.quiz,
                              title: 'Jumlah Soal',
                              value: '$questionCount soal',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.star,
                              title: 'Skor Maksimal',
                              value: '100',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Instructions
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Petunjuk:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildInstructionItem(
                              'Bacalah setiap pertanyaan dengan teliti',
                            ),
                            _buildInstructionItem(
                              'Pilih jawaban yang paling tepat',
                            ),
                            _buildInstructionItem(
                              'Anda tidak dapat kembali ke soal sebelumnya',
                            ),
                            _buildInstructionItem(
                              'Pastikan koneksi internet stabil',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Start Quiz Button or Show Result Button
                      _buildActionButton(quizProvider, questionCount),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildUserScoreCard(QuizProvider quizProvider) {
    final userScore = _getUserScore(quizProvider);
    if (userScore.isEmpty) return SizedBox.shrink();

    final score = userScore['score'] ?? 0;
    final maxScore = userScore['max_score'] ?? 100;
    final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0;
    final isPassed = userScore['is_passed'] ?? (percentage >= 70);
    final completedAt = userScore['completed_at'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPassed
              ? [Colors.green[50]!, Colors.green[100]!]
              : [Colors.red[50]!, Colors.red[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPassed ? Colors.green[200]! : Colors.red[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPassed ? Colors.green : Colors.red).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPassed ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPassed
                          ? 'Kuis Selesai - Lulus'
                          : 'Kuis Selesai - Belum Lulus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Skor: $score/$maxScore (${percentage.toInt()}%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPassed ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    if (completedAt.isNotEmpty)
                      Text(
                        'Diselesaikan: ${_formatDate(completedAt)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue[600]),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Mulai Kuis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin memulai kuis ini?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan Anda siap dan tidak akan terganggu selama mengerjakan kuis.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Mulai',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionPage(quiz: widget.quiz),
      ),
    );
  }

  // Check if user has completed this quiz
  bool _hasCompletedQuiz(QuizProvider quizProvider) {
    if (quizProvider.userScoresList.isEmpty) return false;

    final quizId = widget.quiz['id'];
    return quizProvider.userScoresList.any(
      (score) => score['quiz_id'] == quizId,
    );
  }

  // Get user's score for this quiz
  Map<String, dynamic> _getUserScore(QuizProvider quizProvider) {
    if (quizProvider.userScoresList.isEmpty) return {};

    final quizId = widget.quiz['id'];
    return quizProvider.userScoresList.firstWhere(
      (score) => score['quiz_id'] == quizId,
      orElse: () => {},
    );
  }

  // Navigate to quiz result page with proper data
  void _showQuizResult() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final userScore = _getUserScore(quizProvider);

    if (userScore.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data hasil kuis tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch questions for this quiz
      await quizProvider.fetchSoalList(widget.quiz['id']);

      // Hide loading
      Navigator.pop(context);

      final questions = quizProvider.soalList;
      final List<Map<String, dynamic>> userAnswers = [];

      // Convert user's answers to the format expected by QuizReviewPage
      if (userScore['answers'] != null) {
        for (var answer in userScore['answers']) {
          final questionId = answer['question_id']?.toString() ?? '';
          final selectedOptionLabel =
              answer['selected_option']?.toString() ?? '';

          // Find the option ID based on the option label (A, B, C, D)
          String selectedOptionId = '';
          final question = questions.firstWhere(
            (q) => q['id'].toString() == questionId,
            orElse: () => {},
          );

          if (question.isNotEmpty && question['options'] != null) {
            final options = question['options'] as List;
            final option = options.firstWhere(
              (opt) => opt['option_label'] == selectedOptionLabel,
              orElse: () => {},
            );

            if (option.isNotEmpty) {
              selectedOptionId = option['id'].toString();
            }
          }

          if (selectedOptionId.isNotEmpty) {
            userAnswers.add({
              'questionId': questionId,
              'selectedOptionId': selectedOptionId,
            });
          }
        }
      }

      // Create quiz result data for QuizReviewPage
      final quizResult = {
        'score': userScore['score'] ?? 0,
        'max_score': userScore['max_score'] ?? questions.length,
        'is_passed': userScore['is_passed'] ?? false,
        'message': userScore['is_passed'] == true
            ? 'Selamat! Anda Lulus!'
            : 'Maaf, Anda Belum Lulus',
        'time_taken': userScore['time_taken'],
      };

      // Navigate to QuizReviewPage with complete data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizReviewPage(
            questions: questions,
            userAnswers: userAnswers,
            quiz: widget.quiz,
            quizResult: quizResult,
          ),
        ),
      );
    } catch (e) {
      // Hide loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build the action button (Start Quiz or Show Result)
  Widget _buildActionButton(QuizProvider quizProvider, int questionCount) {
    final hasCompleted = _hasCompletedQuiz(quizProvider);

    return CustomButton(
      label: hasCompleted ? 'Lihat Hasil & Review' : 'Mulai Kuis',
      onPressed: questionCount > 0
          ? () {
              hasCompleted ? _showQuizResult() : _showStartQuizDialog();
            }
          : null,
      backgroundColor: hasCompleted ? Colors.blue : Colors.green,
    );
  }

  // Format date string
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
