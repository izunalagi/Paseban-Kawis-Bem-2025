import 'package:flutter/material.dart';
import '../services/modul_service.dart';
import '../services/auth_service.dart';

class ModulProvider with ChangeNotifier {
  List<dynamic> modul = [];
  bool isLoading = false;
  String? error;

  final ModulService _service = ModulService();

  // Helper method untuk konversi ID ke int dengan aman
  int _parseId(dynamic id) {
    if (id == null) throw Exception('ID tidak boleh null');
    if (id is int) return id;
    if (id is String) {
      final parsed = int.tryParse(id);
      if (parsed == null) throw Exception('ID tidak valid: $id');
      return parsed;
    }
    throw Exception('Tipe ID tidak didukung: ${id.runtimeType}');
  }

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

  // FIXED: Accept dynamic id instead of int
  Future<void> editModul(
    dynamic id, // Changed from int to dynamic
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
      final parsedId = _parseId(id); // Parse for comparison
      final idx = modul.indexWhere((m) => _parseId(m['id']) == parsedId);
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

  // FIXED: Accept dynamic id instead of int
  Future<void> deleteModul(dynamic id) async {
    // Changed from int to dynamic
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
      final parsedId = _parseId(id); // Parse for comparison
      modul.removeWhere((m) => _parseId(m['id']) == parsedId);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // NEW: Method to record module access
  Future<void> recordModuleAccess(dynamic modulId) async {
    try {
      await _service.recordModuleAccess(modulId);
    } catch (e) {
      // Log error but don't throw - this is not critical functionality
      print('Error recording module access: $e');
    }
  }

  // NEW: Method to get recently accessed modules
  Future<List<dynamic>> getRecentlyAccessed() async {
    try {
      return await _service.getRecentlyAccessed();
    } catch (e) {
      print('Error loading recently accessed modules: $e');
      return []; // Return empty list instead of throwing
    }
  }
}
