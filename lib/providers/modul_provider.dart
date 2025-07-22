import 'package:flutter/material.dart';
import '../services/modul_service.dart';
import '../services/auth_service.dart';

class ModulProvider with ChangeNotifier {
  List<dynamic> modul = [];
  bool isLoading = false;
  String? error;

  final ModulService _service = ModulService();

  Future<void> fetchModul() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      modul = await _service.fetchModul();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addModul(
    Map<String, dynamic> data,
    String? pdfPath,
    String? fotoPath,
  ) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data modul',
      );
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final newModul = await _service.addModul(data, pdfPath, fotoPath);
      modul.add(newModul);
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      throw error!;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> editModul(
    int id,
    Map<String, dynamic> data,
    String? pdfPath,
    String? fotoPath,
  ) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data modul',
      );
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final updated = await _service.editModul(id, data, pdfPath, fotoPath);
      final idx = modul.indexWhere((m) => m['id'] == id);
      if (idx != -1) modul[idx] = updated;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      throw error!;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteModul(int id) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data modul',
      );
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteModul(id);
      modul.removeWhere((m) => m['id'] == id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
