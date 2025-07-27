import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  List<dynamic> quizList = [];
  bool isLoading = false;
  String? error;

  List<dynamic> soalList = [];
  bool isLoadingSoal = false;
  String? errorSoal;

  List<dynamic> pilihanList = [];
  bool isLoadingPilihan = false;
  String? errorPilihan;

  final QuizService _service = QuizService();

  Future<void> fetchQuizList() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      quizList = await _service.fetchQuizList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSoalList(int quizId) async {
    isLoadingSoal = true;
    errorSoal = null;
    notifyListeners();
    try {
      soalList = await _service.fetchSoalList(quizId);
    } catch (e) {
      errorSoal = e.toString();
    }
    isLoadingSoal = false;
    notifyListeners();
  }

  Future<void> fetchPilihanList(int questionId) async {
    isLoadingPilihan = true;
    errorPilihan = null;
    notifyListeners();
    try {
      pilihanList = await _service.fetchPilihanList(questionId);
    } catch (e) {
      errorPilihan = e.toString();
    }
    isLoadingPilihan = false;
    notifyListeners();
  }

  void setPilihanListFromSoal(int questionId) {
    final soal = soalList.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => null,
    );

    if (soal != null && soal['options'] != null) {
      final options = soal['options'] as List;

      pilihanList = options.map((option) {
        // Debug print untuk melihat data asli dari backend
        print('DEBUG: option[\'is_correct\'] = ${option['is_correct']}');
        print(
          'DEBUG: option[\'is_correct\'] type = ${option['is_correct'].runtimeType}',
        );

        // Normalisasi is_correct dengan lebih robust
        final isCorrectValue = option['is_correct'];
        bool normalizedIsCorrect;

        if (isCorrectValue == true ||
            isCorrectValue == 1 ||
            isCorrectValue == '1' ||
            isCorrectValue == 'true') {
          normalizedIsCorrect = true;
        } else if (isCorrectValue == false ||
            isCorrectValue == 0 ||
            isCorrectValue == '0' ||
            isCorrectValue == 'false') {
          normalizedIsCorrect = false;
        } else {
          // Default ke false jika tidak dikenali
          normalizedIsCorrect = false;
        }

        print('DEBUG: normalizedIsCorrect = $normalizedIsCorrect');

        final normalizedOption = {
          'id': option['id']?.toString() ?? '',
          'option_label': option['option_label']?.toString() ?? '',
          'option_text': option['option_text']?.toString() ?? '',
          'is_correct': normalizedIsCorrect,
          'question_id': option['question_id']?.toString() ?? '',
        };
        return normalizedOption;
      }).toList();
    } else {
      pilihanList = [];
    }

    notifyListeners();
  }

  Future<void> addQuiz({
    required String title,
    required String description,
    String? thumbnailPath,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.addQuiz(
        title: title,
        description: description,
        thumbnailPath: thumbnailPath,
      );
      await fetchQuizList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> editQuiz({
    required int quizId,
    required String title,
    required String description,
    String? thumbnailPath,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.editQuiz(
        quizId: quizId,
        title: title,
        description: description,
        thumbnailPath: thumbnailPath,
      );
      await fetchQuizList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addSoal({
    required int quizId,
    required String questionText,
  }) async {
    isLoadingSoal = true;
    errorSoal = null;
    notifyListeners();
    try {
      await _service.addSoal(quizId: quizId, questionText: questionText);
      await fetchSoalList(quizId);
    } catch (e) {
      errorSoal = e.toString();
    }
    isLoadingSoal = false;
    notifyListeners();
  }

  Future<void> editSoal({
    required int questionId,
    required int quizId,
    required String questionText,
  }) async {
    isLoadingSoal = true;
    errorSoal = null;
    notifyListeners();
    try {
      await _service.editSoal(
        questionId: questionId,
        quizId: quizId,
        questionText: questionText,
      );
      await fetchSoalList(quizId);
    } catch (e) {
      errorSoal = e.toString();
    }
    isLoadingSoal = false;
    notifyListeners();
  }

  Future<void> addPilihan({
    required int questionId,
    required int quizId,
    required String optionLabel,
    required String optionText,
    required bool isCorrect,
  }) async {
    isLoadingPilihan = true;
    errorPilihan = null;
    notifyListeners();
    try {
      await _service.addPilihan(
        questionId: questionId,
        optionLabel: optionLabel,
        optionText: optionText,
        isCorrect: isCorrect,
      );
      await fetchSoalList(quizId);
    } catch (e) {
      errorPilihan = e.toString();
    }
    isLoadingPilihan = false;
    notifyListeners();
  }

  Future<void> editPilihan({
    required int optionId,
    required int questionId,
    required int quizId,
    required String optionLabel,
    required String optionText,
    required bool isCorrect,
  }) async {
    isLoadingPilihan = true;
    errorPilihan = null;
    notifyListeners();
    try {
      await _service.editPilihan(
        optionId: optionId,
        questionId: questionId,
        quizId: quizId,
        optionLabel: optionLabel,
        optionText: optionText,
        isCorrect: isCorrect,
      );
      // Refresh soal list untuk mendapatkan data pilihan yang terupdate
      await fetchSoalList(quizId);
    } catch (e) {
      errorPilihan = e.toString();
      print('DEBUG EDIT: Error editing pilihan: $e');
    }
    isLoadingPilihan = false;
    notifyListeners();
  }

  Future<void> deleteQuiz(int quizId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteQuiz(quizId);
      await fetchQuizList();
    } catch (e) {
      error = e.toString();
      print('DEBUG: Error deleting quiz: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSoal(int questionId, int quizId) async {
    isLoadingSoal = true;
    errorSoal = null;
    notifyListeners();
    try {
      await _service.deleteSoal(questionId);
      await fetchSoalList(quizId);
    } catch (e) {
      errorSoal = e.toString();
      print('DEBUG: Error deleting soal: $e');
    }
    isLoadingSoal = false;
    notifyListeners();
  }

  Future<void> deletePilihan(int optionId, int questionId, int quizId) async {
    isLoadingPilihan = true;
    errorPilihan = null;
    notifyListeners();
    try {
      await _service.deletePilihan(optionId);

      // Refresh soal list untuk mendapatkan data pilihan yang terupdate
      await fetchSoalList(quizId);
    } catch (e) {
      errorPilihan = e.toString();
      print('DEBUG: Error deleting pilihan: $e');
    }
    isLoadingPilihan = false;
    notifyListeners();
  }

  // Tambah method lain (add, edit, delete) jika diperlukan
}
