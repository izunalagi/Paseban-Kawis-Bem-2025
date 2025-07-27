import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? user;
  String? token;
  int? roleId;
  int? totalUser;
  int? totalModul;
  int? totalQuiz;
  int? userAktif;
  bool statistikLoading = false;
  String? statistikError;

  Future<void> login(String email, String password) async {
    final data = await AuthService().login(email, password);
    // Cek verifikasi email, kecuali admin (role_id == 1)
    if ((data['user']['role_id'] ?? 2) != 1 &&
        data['user']['email_verified_at'] == null) {
      throw Exception('EMAIL_NOT_VERIFIED');
    }
    user = UserModel.fromJson(data['user']);
    token = data['token'];
    // roleId bisa diambil dari user jika ada
    roleId = data['user']['role_id'] ?? 2;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
    String telepon,
  ) async {
    final data = await AuthService().register(nama, email, password, telepon);
    return data;
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String kodeOtp) async {
    final data = await AuthService().verifyOtp(email, kodeOtp);
    return data;
  }

  Future<Map<String, dynamic>> verifyForgotOtp(
    String email,
    String kodeOtp,
  ) async {
    final data = await AuthService().verifyForgotOtp(email, kodeOtp);
    return data;
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final data = await AuthService().resetPassword(
      email,
      password,
      passwordConfirmation,
    );
    return data;
  }

  Future<void> logout() async {
    await AuthService().logout();
    user = null;
    token = null;
    roleId = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    if (await AuthService().isLoggedIn()) {
      final userData = await AuthService().getUser();
      if (userData != null) {
        user = UserModel.fromJson(userData);
        // Ambil token dan role_id dari SharedPreferences
        token = await AuthService().getToken();
        roleId = await AuthService().getRoleId() ?? userData['role_id'] ?? 2;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> forgotPassword(String email) async {
    final response = await AuthService().forgotPassword(email);
    // Tidak perlu return apa-apa, error akan dilempar jika gagal
  }

  Future<void> resendRegisterOtp(String email) async {
    await AuthService().resendRegisterOtp(email);
  }

  Future<void> fetchStatistik() async {
    statistikLoading = true;
    statistikError = null;
    notifyListeners();
    try {
      final data = await AuthService().getStatistik();
      totalUser = data['total_user'];
      totalModul = data['total_modul'];
      totalQuiz = data['total_quiz'];
      userAktif = data['user_aktif'];
    } catch (e) {
      statistikError = e.toString();
    }
    statistikLoading = false;
    notifyListeners();
  }
}
