import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class QuizReviewPage extends StatelessWidget {
  final List<dynamic> questions;
  final List<Map<String, dynamic>> userAnswers;
  final Map<String, dynamic>? quiz; // Quiz info for title
  final Map<String, dynamic>? quizResult; // Quiz result data

  const QuizReviewPage({
    super.key,
    required this.questions,
    required this.userAnswers,
    this.quiz,
    this.quizResult,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate score if not provided
    int correctAnswers = 0;
    for (var question in questions) {
      final userAnswer = userAnswers.firstWhere(
        (ans) => ans['questionId'].toString() == question['id'].toString(),
        orElse: () => <String, dynamic>{},
      );
      final userSelected = userAnswer['selectedOptionId']?.toString();
      final options = question['options'] ?? [];
      final correctOption = (options as List).firstWhere(
        (opt) =>
            opt['is_correct'] == true ||
            opt['is_correct'] == 1 ||
            opt['is_correct'] == '1',
        orElse: () => <String, dynamic>{},
      );
      final correctOptionId = correctOption['id']?.toString();

      if (userSelected == correctOptionId) {
        correctAnswers++;
      }
    }

    final finalScore = quizResult?['score'] ?? correctAnswers;
    final maxScore = quizResult?['max_score'] ?? questions.length;
    final percentage = maxScore > 0 ? (finalScore / maxScore) * 100 : 0;
    final isPassed = quizResult?['is_passed'] ?? (percentage >= 70);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Review Kuis', showBackButton: true),
      body: Column(
        children: [
          // Score Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Quiz Title
                if (quiz != null) ...[
                  Text(
                    quiz!['judul'] ?? 'Quiz Review',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Score Display
                Row(
                  children: [
                    // Score Circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed ? Colors.green[50] : Colors.red[50],
                        border: Border.all(
                          color: isPassed ? Colors.green : Colors.red,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${percentage.toInt()}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPassed ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              '$finalScore/$maxScore',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Score Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPassed ? 'Lulus' : 'Belum Lulus',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildScoreInfo('Total Soal', '${questions.length}'),
                          _buildScoreInfo('Jawaban Benar', '$finalScore'),
                          _buildScoreInfo(
                            'Jawaban Salah',
                            '${questions.length - finalScore}',
                          ),
                          if (quizResult?['time_taken'] != null)
                            _buildScoreInfo(
                              'Waktu',
                              '${quizResult!['time_taken']} menit',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Status Message
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPassed ? Colors.green[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    quizResult?['message'] ??
                        (isPassed
                            ? 'Selamat! Anda berhasil menyelesaikan kuis dengan baik'
                            : 'Silakan pelajari kembali materi dan coba lagi'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isPassed ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Questions Review List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              itemBuilder: (context, qIdx) {
                final question = questions[qIdx];
                final options = question['options'] ?? [];
                final userAnswer = userAnswers.firstWhere(
                  (ans) =>
                      ans['questionId'].toString() == question['id'].toString(),
                  orElse: () => <String, dynamic>{},
                );
                final userSelected = userAnswer['selectedOptionId']?.toString();
                final correctOption = (options as List).firstWhere(
                  (opt) =>
                      opt['is_correct'] == true ||
                      opt['is_correct'] == 1 ||
                      opt['is_correct'] == '1',
                  orElse: () => <String, dynamic>{},
                );
                final correctOptionId = correctOption['id']?.toString();
                final isCorrect = userSelected == correctOptionId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green[200]!
                          : (userSelected != null
                                ? Colors.red[200]!
                                : Colors.grey[300]!),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Soal ${qIdx + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green[100]
                                  : (userSelected != null
                                        ? Colors.red[100]
                                        : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : (userSelected != null
                                            ? Icons.cancel
                                            : Icons.help_outline),
                                  size: 16,
                                  color: isCorrect
                                      ? Colors.green
                                      : (userSelected != null
                                            ? Colors.red
                                            : Colors.grey[600]),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCorrect
                                      ? 'Benar'
                                      : (userSelected != null
                                            ? 'Salah'
                                            : 'Tidak Dijawab'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect
                                        ? Colors.green
                                        : (userSelected != null
                                              ? Colors.red
                                              : Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Question Text
                      Text(
                        question['question_text'] ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Options
                      ...options.map<Widget>((opt) {
                        final optId = opt['id'].toString();
                        final isCorrectOption = optId == correctOptionId;
                        final isUserSelection = optId == userSelected;
                        Color? bgColor;
                        Color? borderColor;
                        Color? textColor = Colors.black87;

                        if (isCorrectOption && isUserSelection) {
                          // User selected correct answer
                          bgColor = Colors.green[100];
                          borderColor = Colors.green;
                          textColor = Colors.green[900];
                        } else if (isCorrectOption) {
                          // Correct answer (not selected by user)
                          bgColor = Colors.green[50];
                          borderColor = Colors.green;
                          textColor = Colors.green[900];
                        } else if (isUserSelection) {
                          // User selected wrong answer
                          bgColor = Colors.red[100];
                          borderColor = Colors.red;
                          textColor = Colors.red[900];
                        } else {
                          // Other options
                          bgColor = Colors.white;
                          borderColor = Colors.grey[300];
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: borderColor ?? Colors.grey,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCorrectOption
                                      ? Colors.green
                                      : isUserSelection
                                      ? Colors.red
                                      : Colors.grey[300],
                                ),
                                child: Text(
                                  opt['option_label'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt['option_text'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: isCorrectOption
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCorrectOption)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                              if (isUserSelection && !isCorrectOption)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
