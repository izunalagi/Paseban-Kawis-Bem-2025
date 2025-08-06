import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'quiz_review_page.dart';

class QuizQuestionPage extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizQuestionPage({super.key, required this.quiz});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> answers = [];
  bool isQuizCompleted = false;
  int score = 0;
  int totalQuestions = 0;
  bool isLoading = true;
  List<dynamic> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      await quizProvider.fetchSoalList(widget.quiz['id']);

      setState(() {
        questions = quizProvider.soalList;
        totalQuestions = questions.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat soal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectAnswer(String optionId) {
    if (currentQuestionIndex < questions.length) {
      setState(() {
        // Find existing answer for current question
        int existingAnswerIndex = answers.indexWhere(
          (answer) =>
              answer['questionId'] == questions[currentQuestionIndex]['id'],
        );

        // If tapping the same option, remove the answer (deselect)
        if (existingAnswerIndex != -1 &&
            answers[existingAnswerIndex]['selectedOptionId'] == optionId) {
          answers.removeAt(existingAnswerIndex);
        }
        // If selecting a different option or first time selecting
        else {
          // Remove old answer if exists
          if (existingAnswerIndex != -1) {
            answers.removeAt(existingAnswerIndex);
          }

          // Add new answer
          answers.add({
            'questionId': questions[currentQuestionIndex]['id'],
            'selectedOptionId': optionId,
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      isQuizCompleted = true;
    });

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      // Debug print for answers
      print('Debug - All Answers:');
      for (var answer in answers) {
        print('Question ID: ${answer['questionId']}');
        print('Selected Option: ${answer['selectedOptionId']}');
        print('Is Correct: ${answer['isCorrect']}');
      }

      // Prepare answers in the format expected by the backend (list of maps)
      List<Map<String, dynamic>> answersToSubmit = answers.map((answer) {
        final question = questions.firstWhere(
          (q) => q['id'].toString() == answer['questionId'].toString(),
          orElse: () => null,
        );
        String? selectedLabel;
        if (question != null && question['options'] != null) {
          final option = (question['options'] as List).firstWhere(
            (opt) =>
                opt['id'].toString() == answer['selectedOptionId'].toString(),
            orElse: () => null,
          );
          if (option != null) {
            selectedLabel = option['option_label']?.toString();
          }
        }
        return {
          'question_id': int.parse(answer['questionId'].toString()),
          'selected_option': selectedLabel ?? '',
        };
      }).toList();

      // Debug print for submission data
      print('Debug - Submitting Quiz:');
      print('Quiz ID: ${widget.quiz['id']}');
      print('Answers to submit: $answersToSubmit');

      await quizProvider.submitQuizAnswers(
        quizId: widget.quiz['id'],
        answers: answersToSubmit,
      );

      // Update score from backend result if available
      if (quizProvider.quizResult != null) {
        setState(() {
          score = quizProvider.quizResult!['score'] ?? score;
        });
      }
    } catch (e, stackTrace) {
      print('Debug - Error submitting quiz:');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal submit kuis: $e'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Detail',
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Detail Error'),
                  content: SingleChildScrollView(
                    child: Text('$e\n\nStack Trace:\n$stackTrace'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  bool _isQuestionAnswered(int questionIndex) {
    return answers.any(
      (answer) => answer['questionId'] == questions[questionIndex]['id'],
    );
  }

  String? _getSelectedAnswer(int questionIndex) {
    final answer = answers.firstWhere(
      (answer) => answer['questionId'] == questions[questionIndex]['id'],
      orElse: () => <String, dynamic>{},
    );
    return answer['selectedOptionId'];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'Kuis', showBackButton: true),
        body: LoadingWidget(),
      );
    }

    if (isQuizCompleted) {
      return _buildQuizResult();
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'Kuis', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Tidak ada soal tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Silakan hubungi admin untuk menambahkan soal',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['options'] ?? [];
    final isAnswered = _isQuestionAnswered(currentQuestionIndex);
    final selectedAnswer = _getSelectedAnswer(currentQuestionIndex);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Kuis: ${widget.quiz['judul'] ?? 'Quiz'}',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soal ${currentQuestionIndex + 1} dari $totalQuestions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Skor: $score/$totalQuestions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / totalQuestions,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ],
              ),
            ),

            // Question Content & Options (scrollable only this part)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.quiz,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Pertanyaan ${currentQuestionIndex + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            currentQuestion['question_text'] ??
                                'Pertanyaan tidak tersedia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Options
                    Text(
                      'Pilih jawaban yang benar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),

                    ...options.asMap().entries.map((entry) {
                      final option = entry.value;
                      final optionId = option['id']?.toString() ?? '';
                      final optionText = option['option_text'] ?? '';
                      final optionLabel = option['option_label'] ?? '';
                      final isSelected = selectedAnswer == optionId;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _selectAnswer(optionId);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.accent
                                          : Colors.grey[300],
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : Text(
                                            optionLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (sticky at bottom)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 8),
                            Text('Sebelumnya'),
                          ],
                        ),
                      ),
                    ),
                  if (currentQuestionIndex > 0) SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAnswered ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentQuestionIndex == questions.length - 1
                                ? 'Selesai'
                                : 'Selanjutnya',
                          ),
                          if (currentQuestionIndex < questions.length - 1) ...[
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResult() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isSubmittingQuiz) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: CustomAppBar(title: 'Hasil Kuis', showBackButton: true),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mengirim jawaban...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (quizProvider.errorSubmitQuiz != null) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: CustomAppBar(title: 'Hasil Kuis', showBackButton: true),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    quizProvider.errorSubmitQuiz!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex = 0;
                        answers.clear();
                        score = 0;
                        isQuizCompleted = false;
                      });
                      quizProvider.clearQuizResult();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get result data from provider or use local data as fallback
        final resultData = quizProvider.quizResult;
        final finalScore = resultData?['score'] ?? score;
        final maxScore = resultData?['max_score'] ?? totalQuestions;
        final percentage = maxScore > 0 ? (finalScore / maxScore) * 100 : 0;
        final isPassed = resultData?['is_passed'] ?? (percentage >= 70);
        final message =
            resultData?['message'] ??
            (isPassed ? 'Selamat! Anda Lulus!' : 'Maaf, Anda Belum Lulus');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(title: 'Hasil Kuis', showBackButton: true),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Result Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Score Circle
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPassed ? Colors.green[50] : Colors.red[50],
                          border: Border.all(
                            color: isPassed ? Colors.green : Colors.red,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${percentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isPassed ? Colors.green : Colors.red,
                                ),
                              ),
                              Text(
                                '$finalScore/$maxScore',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Result Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8),

                      Text(
                        isPassed
                            ? 'Anda berhasil menyelesaikan kuis dengan baik'
                            : 'Silakan coba lagi untuk meningkatkan skor Anda',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24),

                      // Quiz Info
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildResultInfo(
                              'Judul Kuis',
                              widget.quiz['judul'] ?? 'Quiz',
                            ),
                            SizedBox(height: 8),
                            _buildResultInfo(
                              'Total Soal',
                              '$totalQuestions soal',
                            ),
                            SizedBox(height: 8),
                            _buildResultInfo(
                              'Jawaban Benar',
                              '$finalScore soal',
                            ),
                            SizedBox(height: 8),
                            _buildResultInfo(
                              'Jawaban Salah',
                              '${totalQuestions - finalScore} soal',
                            ),
                            if (resultData?['time_taken'] != null) ...[
                              SizedBox(height: 8),
                              _buildResultInfo(
                                'Waktu Pengerjaan',
                                '${resultData!['time_taken']} menit',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Kembali ke Beranda'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizReviewPage(
                                questions: questions,
                                userAnswers: answers,
                                quiz: widget.quiz, // Pass quiz data
                                quizResult:
                                    quizProvider.quizResult, // Pass quiz result
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Review Jawaban'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
