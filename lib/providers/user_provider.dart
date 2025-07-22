import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  List<dynamic> users = [];
  bool isLoading = false;
  String? error;

  final UserService _service = UserService();

  Future<void> fetchUserList() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      users = await _service.fetchUserList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception('Akses ditolak: hanya admin yang boleh menghapus user');
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteUser(id);
      users.removeWhere((u) => u['id'] == id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
