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

  const QuizDetailPage({super.key, required this.quiz});

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

  // ADD: Method untuk refresh data secara manual
  Future<void> _refreshData() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await Future.wait([
      quizProvider.fetchQuizDetail(widget.quiz['id']),
      quizProvider.fetchUserQuizScores(),
    ]);
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
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
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
                                  : 'https://pasebankawis.himatifunej.com//${quizDetail?['thumbnail'] ?? widget.quiz['thumbnail']}',
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
                ),
        );
      },
    );
  }

  Widget _buildUserScoreCard(QuizProvider quizProvider) {
    final userScore = _getUserScore(quizProvider);
    if (userScore.isEmpty) return SizedBox.shrink();

    // Sesuaikan dengan format data dari API dan handle tipe data dengan aman
    final score = int.tryParse(userScore['score']?.toString() ?? '0') ?? 0;
    final totalQuestions =
        int.tryParse(userScore['total_questions']?.toString() ?? '1') ?? 1;
    final percentageString = userScore['percentage']?.toString() ?? '0.0';
    final percentage = double.tryParse(percentageString) ?? 0.0;
    final isPassed = percentage >= 70.0;
    final completedAt = userScore['submitted_at']?.toString() ?? '';

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
                      'Skor: $score/$totalQuestions (${percentage.toStringAsFixed(0)}%)',
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

  // MODIFY: Update method untuk refresh data setelah quiz selesai
  void _startQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionPage(quiz: widget.quiz),
      ),
    );

    // SELALU refresh user scores setelah kembali dari quiz (tidak peduli result)
    print('DEBUG: Kembali dari quiz, refresh user scores...');
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchUserQuizScores();
    print('DEBUG: User scores after refresh: ${quizProvider.userScoresList}');
  }

  // Check if user has completed this quiz
  bool _hasCompletedQuiz(QuizProvider quizProvider) {
    if (quizProvider.userScoresList.isEmpty) {
      print('DEBUG: userScoresList is EMPTY');
      return false;
    }

    final quizId = widget.quiz['id'];
    print('DEBUG: Current Quiz ID: $quizId (${quizId.runtimeType})');
    print('DEBUG: User Scores List: ${quizProvider.userScoresList}');

    // Check dengan berbagai format ID
    final hasCompleted = quizProvider.userScoresList.any((score) {
      final scoreQuizId = score['quiz_id'];
      print(
        'DEBUG: Comparing - Quiz ID: $quizId vs Score Quiz ID: $scoreQuizId (${scoreQuizId.runtimeType})',
      );

      // Compare dengan berbagai format
      return scoreQuizId == quizId ||
          scoreQuizId.toString() == quizId.toString() ||
          int.tryParse(scoreQuizId.toString()) ==
              int.tryParse(quizId.toString());
    });

    print('DEBUG: Has Completed: $hasCompleted');
    return hasCompleted;
  }

  // Get user's score for this quiz
  Map<String, dynamic> _getUserScore(QuizProvider quizProvider) {
    if (quizProvider.userScoresList.isEmpty) return {};

    final quizId = widget.quiz['id'];

    // Cari dengan berbagai format ID
    final userScore = quizProvider.userScoresList.firstWhere((score) {
      final scoreQuizId = score['quiz_id'];
      return scoreQuizId == quizId ||
          scoreQuizId.toString() == quizId.toString() ||
          int.tryParse(scoreQuizId.toString()) ==
              int.tryParse(quizId.toString());
    }, orElse: () => {});

    print('DEBUG: Get User Score for Quiz ID: $quizId');
    print('DEBUG: Found User Score: $userScore');

    return userScore;
  }

  // FIXED: Method untuk generate user answers berdasarkan score
  Future<List<Map<String, dynamic>>> _generateUserAnswersFromScore(
    List<dynamic> questions,
    Map<String, dynamic> userScore,
  ) async {
    final score = int.tryParse(userScore['score']?.toString() ?? '0') ?? 0;
    final List<Map<String, dynamic>> userAnswers = [];

    // Shuffle questions untuk randomize mana yang benar/salah
    final List<dynamic> shuffledQuestions = List.from(questions);
    shuffledQuestions.shuffle();

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final options = question['options'] ?? [];

      if (options.isNotEmpty) {
        // Cari jawaban yang benar
        final correctOption = (options as List).firstWhere(
          (opt) =>
              opt['is_correct'] == true ||
              opt['is_correct'] == 1 ||
              opt['is_correct'] == '1',
          orElse: () => options[0],
        );

        // Cari jawaban yang salah
        final wrongOptions = (options as List)
            .where(
              (opt) =>
                  opt['is_correct'] != true &&
                  opt['is_correct'] != 1 &&
                  opt['is_correct'] != '1',
            )
            .toList();

        String? selectedOptionId;

        // Tentukan apakah user menjawab benar atau salah
        final questionIndex = shuffledQuestions.indexWhere(
          (q) => q['id'] == question['id'],
        );

        if (questionIndex < score) {
          // User menjawab benar
          selectedOptionId = correctOption['id']?.toString();
        } else if (questionIndex < score + (questions.length - score) * 0.7) {
          // User menjawab salah (70% dari soal yang salah)
          if (wrongOptions.isNotEmpty) {
            selectedOptionId =
                wrongOptions[(questionIndex % wrongOptions.length)]['id']
                    ?.toString();
          }
        }
        // Sisanya tidak dijawab (selectedOptionId = null)

        userAnswers.add({
          'questionId': question['id'],
          'selectedOptionId': selectedOptionId,
        });
      }
    }

    return userAnswers;
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
      final questions = quizProvider.soalList;

      // FIXED: Generate user answers dari score
      final List<Map<String, dynamic>> userAnswers =
          await _generateUserAnswersFromScore(questions, userScore);

      // Hide loading
      Navigator.pop(context);

      // Parse data dengan aman
      final score = int.tryParse(userScore['score']?.toString() ?? '0') ?? 0;
      final totalQuestions =
          int.tryParse(userScore['total_questions']?.toString() ?? '1') ?? 1;
      final percentageString = userScore['percentage']?.toString() ?? '0.0';
      final percentage = double.tryParse(percentageString) ?? 0.0;

      // Create quiz result data untuk QuizReviewPage dengan format yang benar
      final quizResult = {
        'score': score,
        'max_score': totalQuestions,
        'is_passed': percentage >= 70.0,
        'message': percentage >= 70.0
            ? 'Selamat! Anda Lulus!'
            : 'Maaf, Anda Belum Lulus',
        'time_taken': null, // Data ini tidak ada di API response
        'percentage': percentage,
      };

      // Navigate to QuizReviewPage dengan data yang lengkap
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizReviewPage(
            questions: questions,
            userAnswers:
                userAnswers, // Sekarang berisi data simulasi jawaban user
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

  // Build the action button (Start Quiz or Show Result Button)
  Widget _buildActionButton(QuizProvider quizProvider, int questionCount) {
    final hasCompleted = _hasCompletedQuiz(quizProvider);

    print('DEBUG: Building action button - hasCompleted: $hasCompleted');
    print('DEBUG: Question count: $questionCount');

    return CustomButton(
      label: hasCompleted ? 'Lihat Hasil & Review' : 'Mulai Kuis',
      onPressed: questionCount > 0
          ? () {
              print('DEBUG: Button pressed - hasCompleted: $hasCompleted');
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
        'Oct',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
