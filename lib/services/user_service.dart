import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<dynamic>> fetchUserList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse('$baseUrl/api/akun/user-list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Gagal mengambil data user',
      );
    }
  }

  Future<void> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.delete(
      Uri.parse('$baseUrl/api/akun/user/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Gagal hapus user');
    }
  }
}
