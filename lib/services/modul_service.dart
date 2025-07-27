import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ModulService {
  static const String baseUrl = 'http://10.179.12.86:8000';

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
}
