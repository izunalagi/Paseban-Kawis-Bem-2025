import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ModulService {
  static const String baseUrl = 'https://pasebankawis.himatifunej.com';

  // Helper method untuk konversi ID ke int dengan aman
  int _parseId(dynamic id) {
    if (id == null) throw Exception('ID tidak boleh null');
    if (id is int) return id;
    if (id is String) {
      final parsed = int.tryParse(id);
      if (parsed == null) throw Exception('ID tidak valid: $id');
      return parsed;
    }
    throw Exception('Tipe ID tidak didukung: ${id.runtimeType}');
  }

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

  // FIXED: Accept dynamic id and parse safely
  Future<Map<String, dynamic>> editModul(
    dynamic id, // Changed from int to dynamic
    Map<String, dynamic> data,
    String? pdfPath,
    String? fotoPath,
  ) async {
    final token = await AuthService().getToken();
    final parsedId = _parseId(id); // Safe parsing

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/modul/$parsedId'),
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

  // FIXED: Accept dynamic id and parse safely
  Future<void> deleteModul(dynamic id) async {
    // Changed from int to dynamic
    final token = await AuthService().getToken();
    final parsedId = _parseId(id); // Safe parsing

    final res = await http.delete(
      Uri.parse('$baseUrl/api/modul/$parsedId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal hapus modul');
    }
  }

  // FIXED: Accept dynamic modulId and parse safely
  Future<void> recordModuleAccess(dynamic modulId) async {
    // Changed from int to dynamic
    final token = await AuthService().getToken();
    final parsedId = _parseId(modulId); // Safe parsing

    final res = await http.post(
      Uri.parse('$baseUrl/api/modul/$parsedId/access'),
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
