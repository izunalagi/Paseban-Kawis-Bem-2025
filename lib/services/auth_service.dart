import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';

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
        // Simpan role_id secara eksplisit
        if (data['user'] != null && data['user']['role_id'] != null) {
          await prefs.setInt('role_id', data['user']['role_id']);
        }
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

  Future<Map<String, dynamic>> verifyForgotOtp(
    String email,
    String kodeOtp,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/verify-forgot-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': kodeOtp}),
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

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Reset password gagal',
        );
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Gagal mengirim OTP',
        );
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }

  Future<void> resendRegisterOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/resend-register-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Gagal mengirim ulang OTP',
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

  // Getter untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Getter untuk mengambil role_id dari SharedPreferences
  Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('role_id');
  }
}
