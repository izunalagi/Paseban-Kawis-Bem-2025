import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ModulService {
  static const String baseUrl = 'http://10.42.223.86:8000';

  Future<List<dynamic>> fetchModul() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/modul'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Gagal mengambil data modul');
    }
  }

  Future<Map<String, dynamic>> addModul(
    Map<String, dynamic> data,
    String? pdfPath,
    String? fotoPath,
  ) async {
    final token = await AuthService().getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/modul'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (pdfPath != null && pdfPath.isNotEmpty) {
      // Validasi PDF sebelum upload
      final pdfFile = File(pdfPath);
      if (await pdfFile.exists()) {
        final fileSize = await pdfFile.length();
        if (fileSize > 50 * 1024 * 1024) {
          throw Exception('Ukuran file PDF terlalu besar (maksimal 50MB)');
        }
        // Cek ekstensi file
        if (!pdfPath.toLowerCase().endsWith('.pdf')) {
          throw Exception('File harus berformat PDF');
        }
      }
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));
    }
    if (fotoPath != null && fotoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal tambah modul');
    }
  }

  Future<Map<String, dynamic>> editModul(
    int id,
    Map<String, dynamic> data,
    String? pdfPath,
    String? fotoPath,
  ) async {
    final token = await AuthService().getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/modul/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (pdfPath != null && pdfPath.isNotEmpty) {
      // Validasi PDF sebelum upload
      final pdfFile = File(pdfPath);
      if (await pdfFile.exists()) {
        final fileSize = await pdfFile.length();
        if (fileSize > 50 * 1024 * 1024) {
          throw Exception('Ukuran file PDF terlalu besar (maksimal 50MB)');
        }
        // Cek ekstensi file
        if (!pdfPath.toLowerCase().endsWith('.pdf')) {
          throw Exception('File harus berformat PDF');
        }
      }
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));
    }
    if (fotoPath != null && fotoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal ubah modul');
    }
  }

  Future<void> deleteModul(int id) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/modul/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal hapus modul');
    }
  }

  Future<void> recordModuleAccess(int modulId) async {
    final token = await AuthService().getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/modul/$modulId/access'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal mencatat akses modul');
    }
  }

  Future<List<dynamic>> getRecentlyAccessed() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/modul/recently-accessed'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Gagal mengambil modul terakhir diakses');
    }
  }
}
