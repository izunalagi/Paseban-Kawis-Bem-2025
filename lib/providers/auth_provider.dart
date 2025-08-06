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

  // Helper function untuk konversi role_id dengan aman
  int _parseRoleId(dynamic roleIdValue) {
    if (roleIdValue == null) return 2; // default user

    if (roleIdValue is int) {
      return roleIdValue;
    } else if (roleIdValue is String) {
      return int.tryParse(roleIdValue) ?? 2;
    }

    return 2; // fallback ke user
  }

  Future<void> login(String email, String password) async {
    try {
      final data = await AuthService().login(email, password);

      print("📥 Login response data: $data");
      print("👤 User data: ${data['user']}");
      print(
        "🆔 Raw role_id: ${data['user']['role_id']} (type: ${data['user']['role_id'].runtimeType})",
      );

      // Parse role_id dengan aman
      final parsedRoleId = _parseRoleId(data['user']['role_id']);
      print("✅ Parsed role_id: $parsedRoleId");

      // Cek verifikasi email, kecuali admin (role_id == 1)
      if (parsedRoleId != 1 && data['user']['email_verified_at'] == null) {
        print("⚠️ User belum terverifikasi, role_id: $parsedRoleId");
        throw Exception('EMAIL_NOT_VERIFIED');
      }

      user = UserModel.fromJson(data['user']);
      token = data['token'];
      roleId = parsedRoleId;

      print("🎯 Final roleId set: $roleId");
      notifyListeners();
    } catch (e) {
      print("🚨 AuthProvider login error: $e");
      rethrow;
    }
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
    try {
      if (await AuthService().isLoggedIn()) {
        final userData = await AuthService().getUser();
        if (userData != null) {
          print("🔄 Auto login - userData: $userData");

          user = UserModel.fromJson(userData);
          token = await AuthService().getToken();

          // Ambil role_id dari SharedPreferences dulu, fallback ke userData
          final storedRoleId = await AuthService().getRoleId();
          final userDataRoleId = _parseRoleId(userData['role_id']);

          roleId = storedRoleId ?? userDataRoleId;

          print("🎯 Auto login - Final roleId: $roleId");
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("🚨 Auto login error: $e");
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    await AuthService().forgotPassword(email);
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
