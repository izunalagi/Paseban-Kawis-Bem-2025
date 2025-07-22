import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/category_modul_provider.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';

class TambahEditKategoriPage extends StatefulWidget {
  final Map? kategori;
  const TambahEditKategoriPage({super.key, this.kategori});

  @override
  State<TambahEditKategoriPage> createState() => _TambahEditKategoriPageState();
}

class _TambahEditKategoriPageState extends State<TambahEditKategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  bool isLoading = false;
  late BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    if (widget.kategori != null) {
      _namaController.text = widget.kategori!['nama'] ?? '';
    }
  }

  void _showFlushBar(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
    ).show(context);
  }

  Future<void> _submit(CategoryModulProvider prov) async {
    print(
      '[DEBUG] SUBMIT pressed, isEdit=${widget.kategori != null}, nama=${_namaController.text}',
    );
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] Form tidak valid');
      _showFlushBar('Nama kategori wajib diisi', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      if (widget.kategori == null) {
        await prov.addKategori(_namaController.text.trim());
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.pop(context, true);
      } else {
        await prov.editKategori(
          widget.kategori!['id'],
          _namaController.text.trim(),
        );
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[DEBUG KATEGORI ERROR] $e');
      final errorMsg = prov.error ?? e.toString();
      _showFlushBar('Gagal: $errorMsg', isError: true);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    final isEdit = widget.kategori != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Kategori' : 'Tambah Kategori',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Nama kategori wajib diisi';
                    if (v.length > 255) return 'Maksimal 255 karakter';
                    return null;
                  },
                  enabled: !isLoading,
                ),
              ),
              const SizedBox(height: 32),
              Builder(
                builder: (buttonContext) => Consumer<CategoryModulProvider>(
                  builder: (context, prov, _) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isLoading ? null : () => _submit(prov),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
