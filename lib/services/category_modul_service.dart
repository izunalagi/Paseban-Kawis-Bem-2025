import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class CategoryModulService {
  static const String baseUrl = 'http://172.29.207.86:8000';

  Future<List<dynamic>> fetchKategori() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/category_modul'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }

  Future<Map<String, dynamic>> addKategori(String nama) async {
    final token = await AuthService().getToken();
    print('[DEBUG] addKategori request: $nama');
    final response = await http.post(
      Uri.parse('$baseUrl/api/category_modul'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nama': nama}),
    );
    print(
      '[DEBUG] addKategori response:  [38;5;9m${response.statusCode} ${response.body} [0m',
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal tambah kategori',
      );
    }
  }

  Future<Map<String, dynamic>> editKategori(int id, String nama) async {
    final token = await AuthService().getToken();
    print('[DEBUG] editKategori request: id=$id, nama=$nama');
    final response = await http.put(
      Uri.parse('$baseUrl/api/category_modul/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nama': nama}),
    );
    print(
      '[DEBUG] editKategori response:  [38;5;9m${response.statusCode} ${response.body} [0m',
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal edit kategori',
      );
    }
  }

  Future<void> deleteKategori(int id) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/category_modul/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Gagal hapus kategori',
      );
    }
  }
}
