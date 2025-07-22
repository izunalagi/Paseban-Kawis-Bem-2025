import 'package:flutter/material.dart';
import '../services/category_modul_service.dart';
import '../services/auth_service.dart';

class CategoryModulProvider with ChangeNotifier {
  List<dynamic> kategori = [];
  bool isLoading = false;
  String? error;

  final CategoryModulService _service = CategoryModulService();

  Future<void> fetchKategori() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      kategori = await _service.fetchKategori();
    } catch (e) {
      error = e.toString();
      print('[DEBUG] fetchKategori error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addKategori(String nama) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data kategori',
      );
    }
    print('[DEBUG] PROVIDER addKategori dipanggil, nama=$nama');
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final newKategori = await _service.addKategori(nama);
      kategori.add(newKategori);
      print('[DEBUG] Provider: kategori berhasil ditambah');
    } catch (e) {
      error = e.toString();
      print('[DEBUG] Provider: addKategori error: $error');
      isLoading = false;
      notifyListeners();
      throw error!;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> editKategori(int id, String nama) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data kategori',
      );
    }
    print('[DEBUG] PROVIDER editKategori dipanggil, id=$id, nama=$nama');
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final updated = await _service.editKategori(id, nama);
      final idx = kategori.indexWhere((k) => k['id'] == id);
      if (idx != -1) kategori[idx] = updated;
      print('[DEBUG] Provider: kategori berhasil diedit');
    } catch (e) {
      error = e.toString();
      print('[DEBUG] Provider: editKategori error: $error');
      isLoading = false;
      notifyListeners();
      throw error!;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteKategori(int id) async {
    final roleId = await AuthService().getRoleId();
    if (roleId != 1) {
      throw Exception(
        'Akses ditolak: hanya admin yang boleh mengubah data kategori',
      );
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteKategori(id);
      kategori.removeWhere((k) => k['id'] == id);
    } catch (e) {
      error = e.toString();
      print('[DEBUG] deleteKategori error: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
