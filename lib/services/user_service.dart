import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'https://pasebankawis.himatifunej.com';

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

  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Gagal mengambil profil',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String email,
    required String telepon,
    String? fotoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/profile?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama'] = nama;
    request.fields['email'] = email;
    request.fields['telepon'] = telepon;
    if (fotoPath != null && fotoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);

      // Update user data in SharedPreferences
      await _updateUserDataInSharedPreferences(nama, email, telepon);

      return responseData;
    } else {
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Gagal perbarui profil',
      );
    }
  }

  // Method untuk update data user di SharedPreferences
  Future<void> _updateUserDataInSharedPreferences(
    String nama,
    String email,
    String telepon,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        // Update nama, email, dan telepon
        userData['nama'] = nama;
        userData['email'] = email;
        userData['telepon'] = telepon;

        // Simpan kembali ke SharedPreferences
        await prefs.setString('user', jsonEncode(userData));
      }
    } catch (e) {
      print('Error updating user data in SharedPreferences: $e');
    }
  }
}
