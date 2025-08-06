import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class TambahEditQuizPage extends StatefulWidget {
  final Map? quiz;
  const TambahEditQuizPage({super.key, this.quiz});

  @override
  State<TambahEditQuizPage> createState() => _TambahEditQuizPageState();
}

class _TambahEditQuizPageState extends State<TambahEditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _thumbnailPath;
  String? _thumbnailName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!['title'] ?? '';
      _descriptionController.text = widget.quiz!['description'] ?? '';
      _thumbnailName = widget.quiz!['thumbnail']?.toString().split('/').last;
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

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _thumbnailPath = result.files.single.path;
        _thumbnailName = result.files.single.name;
      });
    }
  }

  Future<void> _submit(QuizProvider prov) async {
    if (!_formKey.currentState!.validate()) {
      _showFlushBar('Judul quiz wajib diisi', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      if (widget.quiz == null) {
        await prov.addQuiz(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          thumbnailPath: _thumbnailPath,
        );
        Navigator.pop(context, true);
      } else {
        await prov.editQuiz(
          quizId: widget.quiz!['id'],
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          thumbnailPath: _thumbnailPath,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showFlushBar('Gagal: ${prov.error ?? e.toString()}', isError: true);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.quiz != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isEdit ? 'Ubah Kuis' : 'Tambah Kuis',
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
              // THUMBNAIL PREVIEW & UPLOAD
              Center(
                child: Column(
                  children: [
                    // Preview thumbnail
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: (_thumbnailPath != null)
                            ? DecorationImage(
                                image: FileImage(File(_thumbnailPath!)),
                                fit: BoxFit.cover,
                              )
                            : (widget.quiz != null &&
                                  widget.quiz!['thumbnail'] != null &&
                                  widget.quiz!['thumbnail']
                                      .toString()
                                      .isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(
                                  widget.quiz!['thumbnail'].startsWith('http')
                                      ? widget.quiz!['thumbnail']
                                      : 'https://pasebankawis.himatifunej.com/${widget.quiz!['thumbnail']}',
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              )
                            : null,
                      ),
                      child:
                          (_thumbnailPath == null &&
                              (widget.quiz == null ||
                                  widget.quiz!['thumbnail'] == null ||
                                  widget.quiz!['thumbnail'].toString().isEmpty))
                          ? const Icon(Icons.quiz, size: 48, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    // Instruksi upload thumbnail
                    const Text(
                      'Thumbnail Kuis',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tekan tombol di bawah untuk mengunggah atau mengganti thumbnail kuis.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _pickThumbnail,
                            icon: const Icon(Icons.photo),
                            label: Text(
                              _thumbnailName != null
                                  ? 'Ganti Thumbnail'
                                  : 'Unggah Thumbnail',
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
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kuis',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Judul wajib diisi'
                          : null,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Kuis',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isLoading,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Builder(
                builder: (buttonContext) => Consumer<QuizProvider>(
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
