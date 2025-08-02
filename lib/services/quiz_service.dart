import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = 'http://10.42.223.86:8000';

  // Get all quizzes (listQuiz method in PHP)
  Future<List<dynamic>> fetchQuizList() async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/quiz'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['quizzes'] ?? data ?? [];
      }
      throw Exception('Gagal mengambil data kuis');
    } catch (e) {
      throw Exception('Gagal mengambil data kuis: $e');
    }
  }

  // Get quiz detail with total questions (getQuizDetail method in PHP)
  Future<Map<String, dynamic>> fetchQuizDetail(int quizId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/quiz/$quizId/detail'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['quiz'] ?? {};
      }
      throw Exception('Gagal mengambil detail kuis');
    } catch (e) {
      throw Exception('Gagal mengambil detail kuis: $e');
    }
  }

  // Get questions for a specific quiz (getQuestions method in PHP)
  Future<List<dynamic>> fetchSoalList(int quizId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/quiz/$quizId/questions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['questions'] ?? data ?? [];
      }
      throw Exception('Gagal mengambil data soal');
    } catch (e) {
      throw Exception('Gagal mengambil data soal: $e');
    }
  }

  // Get options for a specific question (not directly in PHP, but options come with questions)
  Future<List<dynamic>> fetchPilihanList(int questionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/questions/$questionId/options'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['options'] ?? data ?? [];
      }
      throw Exception('Gagal mengambil data pilihan');
    } catch (e) {
      throw Exception('Gagal mengambil data pilihan: $e');
    }
  }

  // Get leaderboard (getLeaderboard method in PHP)
  Future<List<dynamic>> fetchLeaderboard({int? quizId}) async {
    try {
      final token = await AuthService().getToken();
      final url = quizId != null
          ? '$baseUrl/api/quiz/$quizId/leaderboard'
          : '$baseUrl/api/leaderboard';
      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['leaderboard'] ?? data ?? [];
      }
      throw Exception('Gagal mengambil data leaderboard');
    } catch (e) {
      throw Exception('Gagal mengambil data leaderboard: $e');
    }
  }

  // Get user quiz scores (getUserQuizScores method in PHP)
  Future<List<dynamic>> fetchUserQuizScores() async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/user/quiz-scores'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['quiz_scores'] ?? data ?? [];
      }
      throw Exception('Gagal mengambil data skor kuis user');
    } catch (e) {
      throw Exception('Gagal mengambil data skor kuis user: $e');
    }
  }

  // Submit quiz answers (submitAnswers method in PHP)
  Future<Map<String, dynamic>> submitQuizAnswers({
    required int quizId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/api/quiz/$quizId/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'answers': answers}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Gagal submit jawaban kuis',
      );
    } catch (e) {
      throw Exception('Gagal submit jawaban kuis: $e');
    }
  }

  // Create quiz (store method in PHP)
  Future<Map<String, dynamic>> addQuiz({
    required String title,
    required String description,
    String? thumbnailPath,
    String? category,
    int? maxScore,
    int? duration,
  }) async {
    try {
      final token = await AuthService().getToken();
      var uri = Uri.parse('$baseUrl/api/quiz');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (maxScore != null) request.fields['max_score'] = maxScore.toString();
      if (duration != null) request.fields['duration'] = duration.toString();

      if (thumbnailPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnailPath),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      }
      throw Exception(
        jsonDecode(responseBody)['message'] ?? 'Gagal tambah kuis',
      );
    } catch (e) {
      throw Exception('Gagal tambah kuis: $e');
    }
  }

  // Update quiz (update method in PHP)
  Future<Map<String, dynamic>> editQuiz({
    required int quizId,
    required String title,
    required String description,
    String? thumbnailPath,
    String? category,
    int? maxScore,
    int? duration,
  }) async {
    try {
      final token = await AuthService().getToken();
      var uri = Uri.parse('$baseUrl/api/quiz/$quizId');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (maxScore != null) request.fields['max_score'] = maxScore.toString();
      if (duration != null) request.fields['duration'] = duration.toString();

      if (thumbnailPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnailPath),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      }
      throw Exception(jsonDecode(responseBody)['message'] ?? 'Gagal ubah kuis');
    } catch (e) {
      throw Exception('Gagal ubah kuis: $e');
    }
  }

  // Delete quiz (destroy method in PHP)
  Future<void> deleteQuiz(int quizId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/$quizId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        throw Exception(errorBody['message'] ?? 'Gagal hapus kuis');
      }
    } catch (e) {
      throw Exception('Gagal hapus kuis: $e');
    }
  }

  // Add question to quiz (addQuestion method in PHP)
  Future<Map<String, dynamic>> addSoal({
    required int quizId,
    required String questionText,
  }) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/api/quiz/$quizId/questions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'question_text': questionText}),
      );

      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal tambah soal');
    } catch (e) {
      throw Exception('Gagal tambah soal: $e');
    }
  }

  // Update question (updateQuestion method in PHP)
  Future<Map<String, dynamic>> editSoal({
    required int questionId,
    required int quizId,
    required String questionText,
  }) async {
    try {
      final token = await AuthService().getToken();

      final res = await http.post(
        Uri.parse('$baseUrl/api/quiz/questions/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'question_text': questionText}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      final errorBody = jsonDecode(res.body);
      throw Exception(errorBody['message'] ?? 'Gagal ubah soal');
    } catch (e) {
      throw Exception('Gagal ubah soal: $e');
    }
  }

  // Delete question (destroyQuestion method in PHP)
  Future<void> deleteSoal(int questionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/questions/$questionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        throw Exception(errorBody['message'] ?? 'Gagal hapus soal');
      }
    } catch (e) {
      throw Exception('Gagal hapus soal: $e');
    }
  }

  // Add option to question (addOption method in PHP)
  Future<Map<String, dynamic>> addPilihan({
    required int questionId,
    required String optionLabel,
    required String optionText,
    required bool isCorrect,
  }) async {
    try {
      final token = await AuthService().getToken();

      final res = await http.post(
        Uri.parse('$baseUrl/api/quiz/questions/$questionId/options'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'option_label': optionLabel,
          'option_text': optionText,
          'is_correct': isCorrect,
        }),
      );

      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      }

      final errorBody = jsonDecode(res.body);
      throw Exception(errorBody['message'] ?? 'Gagal tambah pilihan');
    } catch (e) {
      throw Exception('Gagal tambah pilihan: $e');
    }
  }

  // Update option (updateOption method in PHP)
  Future<Map<String, dynamic>> editPilihan({
    required int optionId,
    required int questionId,
    required int quizId,
    required String optionLabel,
    required String optionText,
    required bool isCorrect,
  }) async {
    try {
      final token = await AuthService().getToken();

      final res = await http.post(
        Uri.parse('$baseUrl/api/quiz/options/$optionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'option_label': optionLabel,
          'option_text': optionText,
          'is_correct': isCorrect,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      final errorBody = jsonDecode(res.body);
      throw Exception(errorBody['message'] ?? 'Gagal ubah pilihan');
    } catch (e) {
      throw Exception('Gagal ubah pilihan: $e');
    }
  }

  // Delete option (destroyOption method in PHP)
  Future<void> deletePilihan(int optionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/options/$optionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        throw Exception(errorBody['message'] ?? 'Gagal hapus pilihan');
      }
    } catch (e) {
      throw Exception('Gagal hapus pilihan: $e');
    }
  }
}
