import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? user;
  String? token;
  int? roleId;

  Future<void> login(String email, String password) async {
    final data = await AuthService().login(email, password);
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
        roleId = userData['role_id'] ?? 2;
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
