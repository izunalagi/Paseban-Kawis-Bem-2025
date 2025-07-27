import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = 'http://10.179.12.86:8000';

  Future<List<dynamic>> fetchQuizList() async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/quiz'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['quizzes'] ?? [];
      }
      throw Exception('Gagal mengambil data kuis');
    } catch (e) {
      throw Exception('Gagal mengambil data kuis');
    }
  }

  Future<List<dynamic>> fetchSoalList(int quizId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/quiz/$quizId/questions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['questions'] ?? [];
      }
      throw Exception('Gagal mengambil data soal');
    } catch (e) {
      throw Exception('Gagal mengambil data soal');
    }
  }

  Future<List<dynamic>> fetchPilihanList(int questionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/api/questions/$questionId/options'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['options'] ?? [];
      }
      throw Exception('Gagal mengambil data pilihan');
    } catch (e) {
      throw Exception('Gagal mengambil data pilihan');
    }
  }

  Future<Map<String, dynamic>> addQuiz({
    required String title,
    required String description,
    String? thumbnailPath,
  }) async {
    try {
      final token = await AuthService().getToken();
      var uri = Uri.parse('$baseUrl/api/quiz');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;

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

  Future<Map<String, dynamic>> editQuiz({
    required int quizId,
    required String title,
    required String description,
    String? thumbnailPath,
  }) async {
    try {
      final token = await AuthService().getToken();
      print('DEBUG: Editing quiz $quizId');
      print('DEBUG: Title: $title');
      print('DEBUG: Description: $description');
      print('DEBUG: ThumbnailPath: $thumbnailPath');

      // Gunakan POST method tanpa _method field
      var uri = Uri.parse('$baseUrl/api/quiz/$quizId');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;

      if (thumbnailPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnailPath),
        );
        print('DEBUG: Added thumbnail file');
      } else {
        print('DEBUG: No thumbnail file');
      }

      print('DEBUG: Request fields: ${request.fields}');
      print('DEBUG: Request files count: ${request.files.length}');
      print('DEBUG: Request URL: ${request.url}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: $responseBody');

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      }
      throw Exception(jsonDecode(responseBody)['message'] ?? 'Gagal ubah kuis');
    } catch (e) {
      print('DEBUG: Error in editQuiz: $e');
      throw Exception('Gagal ubah kuis: $e');
    }
  }

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

  Future<void> deleteQuiz(int quizId) async {
    try {
      final token = await AuthService().getToken();
      print('DEBUG: Deleting quiz $quizId with token: $token');

      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/$quizId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG: Delete response status: ${res.statusCode}');
      print('DEBUG: Delete response body: ${res.body}');

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        throw Exception(errorBody['message'] ?? 'Gagal hapus kuis');
      }
    } catch (e) {
      throw Exception('Gagal hapus kuis: $e');
    }
  }

  Future<void> deleteSoal(int questionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/questions/$questionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG: Delete question response status: ${res.statusCode}');
      print('DEBUG: Delete question response body: ${res.body}');

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        print('DEBUG: Delete question error body: $errorBody');
        throw Exception(errorBody['message'] ?? 'Gagal hapus soal');
      }
    } catch (e) {
      throw Exception('Gagal hapus soal: $e');
    }
  }

  Future<void> deletePilihan(int optionId) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/api/quiz/options/$optionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG: Delete option response status: ${res.statusCode}');
      print('DEBUG: Delete option response body: ${res.body}');

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(res.body);
        print('DEBUG: Delete option error body: $errorBody');
        throw Exception(errorBody['message'] ?? 'Gagal hapus pilihan');
      }
    } catch (e) {
      throw Exception('Gagal hapus pilihan: $e');
    }
  }

  // Tambah method addQuiz, editQuiz, deleteQuiz jika diperlukan
}
