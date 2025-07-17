import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.19:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan token & expired
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        await prefs.setString(
          'token_expired',
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
    String telepon,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nama': nama,
              'email': email,
              'password': password,
              'telepon': telepon,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Registrasi gagal',
        );
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String kodeOtp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'kode_otp': kodeOtp}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Verifikasi OTP gagal',
        );
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final expired = prefs.getString('token_expired');

      if (token != null && expired != null) {
        final expDate = DateTime.parse(expired);
        if (DateTime.now().isBefore(expDate)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        return jsonDecode(userStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignore logout errors
    }
  }
}
