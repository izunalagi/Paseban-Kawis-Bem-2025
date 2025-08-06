import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/modul_provider.dart';
import '../../../providers/category_modul_provider.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../services/modul_service.dart';

class TambahEditModulPage extends StatefulWidget {
  final Map? modul;
  const TambahEditModulPage({super.key, this.modul});

  @override
  State<TambahEditModulPage> createState() => _TambahEditModulPageState();
}

class _TambahEditModulPageState extends State<TambahEditModulPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  int? _selectedKategori;
  String? _pdfPath;
  String? _pdfName;
  String? _fotoPath;
  String? _fotoName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.modul != null) {
      _judulController.text = widget.modul!['judul_modul'] ?? '';
      _linkController.text = widget.modul!['link_video'] ?? '';
      _deskripsiController.text = widget.modul!['deskripsi_modul'] ?? '';
      _selectedKategori = int.tryParse(
        widget.modul!['category_modul_id'].toString(),
      );
      _pdfName = widget.modul!['path_pdf']?.toString().split('/').last;
      _fotoName = widget.modul!['foto']?.toString().split('/').last;
      // _fotoPath = widget.modul!['foto'] != null
      //     ? widget.modul!['foto']
      //     : null;
    }
    // Fetch kategori jika belum ada
    Future.microtask(() {
      final catProv = Provider.of<CategoryModulProvider>(
        context,
        listen: false,
      );
      if (catProv.kategori.isEmpty) catProv.fetchKategori();
    });
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

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();

      // Validasi ukuran file (max 50MB)
      if (fileSize > 50 * 1024 * 1024) {
        _showFlushBar(
          'Ukuran file PDF terlalu besar (maksimal 50MB)',
          isError: true,
        );
        return;
      }

      // Validasi PDF dengan mencoba membaca file
      try {
        final bytes = await file.readAsBytes();

        // Cek ukuran file minimal
        if (bytes.length < 100) {
          _showFlushBar('File PDF terlalu kecil atau rusak', isError: true);
          return;
        }

        // Cek apakah file memiliki ekstensi .pdf
        if (!result.files.single.name.toLowerCase().endsWith('.pdf')) {
          _showFlushBar('File harus berformat PDF', isError: true);
          return;
        }

        // Cek apakah PDF memiliki halaman lebih dari 1 (opsional)
        try {
          final pdfContent = String.fromCharCodes(bytes);
          final pageCount = RegExp(r'/Count\s+(\d+)').firstMatch(pdfContent);
          if (pageCount != null) {
            final count = int.tryParse(pageCount.group(1) ?? '1');
            if (count != null && count > 1) {
              // Tampilkan warning untuk PDF multi-halaman
              _showFlushBar(
                'PDF memiliki $count halaman. Pastikan semua halaman dapat ditampilkan dengan baik.',
                isError: false,
              );
            }
          }
        } catch (e) {
          // Jika gagal membaca jumlah halaman, lanjutkan saja
          print('Tidak dapat membaca jumlah halaman PDF: $e');
        }

        setState(() {
          _pdfPath = result.files.single.path;
          _pdfName = result.files.single.name;
        });
      } catch (e) {
        _showFlushBar('Gagal membaca file PDF: $e', isError: true);
      }
    }
  }

  Future<void> _pickFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fotoPath = result.files.single.path;
        _fotoName = result.files.single.name;
      });
    }
  }

  Future<void> _submit(ModulProvider prov) async {
    if (!_formKey.currentState!.validate()) {
      _showFlushBar('Semua field wajib diisi', isError: true);
      return;
    }
    if (_selectedKategori == null) {
      _showFlushBar('Pilih kategori modul', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = {
        'judul_modul': _judulController.text.trim(),
        'category_modul_id': _selectedKategori,
        'link_video': _linkController.text.trim(),
        'deskripsi_modul': _deskripsiController.text.trim(),
      };
      if (widget.modul == null) {
        await prov.addModul(data, _pdfPath, _fotoPath);
        Navigator.pop(context, true);
      } else {
        await prov.editModul(widget.modul!['id'], data, _pdfPath, _fotoPath);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showFlushBar('Gagal: ${prov.error ?? e.toString()}', isError: true);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.modul != null;
    final kategoriList = Provider.of<CategoryModulProvider>(context).kategori;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isEdit ? 'Ubah Modul' : 'Tambah Modul',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // FOTO PREVIEW & UPLOAD
              Center(
                child: Column(
                  children: [
                    // Preview foto
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: (_fotoPath != null)
                            ? DecorationImage(
                                image: FileImage(File(_fotoPath!)),
                                fit: BoxFit.cover,
                              )
                            : (widget.modul != null &&
                                  widget.modul!['foto'] != null)
                            ? DecorationImage(
                                image: NetworkImage(
                                  '${ModulService.baseUrl}/${widget.modul!['foto']}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_fotoPath == null &&
                              (widget.modul == null ||
                                  widget.modul!['foto'] == null))
                          ? const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    // Instruksi upload foto
                    const Text(
                      'Foto Modul',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tekan tombol di bawah untuk mengunggah atau mengganti foto modul.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _pickFoto,
                            icon: const Icon(Icons.photo),
                            label: Text(
                              _fotoName != null ? 'Ganti Foto' : 'Unggah Foto',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Modul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Judul wajib diisi'
                          : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedKategori,
                      items: kategoriList.map<DropdownMenuItem<int>>((k) {
                        return DropdownMenuItem(
                          value: k['id'],
                          child: Text(k['nama'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _selectedKategori = v),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link Video',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Link video wajib diisi'
                          : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Modul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Deskripsi wajib diisi'
                          : null,
                      enabled: !isLoading,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // PDF SECTION
                    const Text(
                      'PDF Modul',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tekan tombol di bawah untuk mengunggah atau mengganti file PDF modul.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        '⚠️ Catatan: PDF dengan halaman lebih dari 1 mungkin memerlukan waktu loading lebih lama. Pastikan file PDF tidak lebih dari 50MB.',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _pickPdf,
                            icon: const Icon(Icons.attach_file),
                            label: Text(
                              _pdfName ?? 'Unggah PDF',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Builder(
                builder: (buttonContext) => Consumer<ModulProvider>(
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
