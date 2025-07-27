import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';

class TambahEditSoalPage extends StatefulWidget {
  final int quizId;
  final Map? soal;
  const TambahEditSoalPage({super.key, required this.quizId, this.soal});

  @override
  State<TambahEditSoalPage> createState() => _TambahEditSoalPageState();
}

class _TambahEditSoalPageState extends State<TambahEditSoalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.soal != null) {
      _questionController.text = widget.soal!['question_text'] ?? '';
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

  Future<void> _submit(QuizProvider prov) async {
    if (!_formKey.currentState!.validate()) {
      _showFlushBar('Teks soal wajib diisi', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      if (widget.soal == null) {
        await prov.addSoal(
          quizId: widget.quizId,
          questionText: _questionController.text.trim(),
        );
        Navigator.pop(context, true);
      } else {
        await prov.editSoal(
          questionId: widget.soal!['id'],
          quizId: widget.quizId,
          questionText: _questionController.text.trim(),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showFlushBar('Gagal: ${prov.errorSoal ?? e.toString()}', isError: true);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.soal != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isEdit ? 'Ubah Soal' : 'Tambah Soal',
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
              // Judul dan instruksi
              const Text(
                'Teks Soal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan pertanyaan yang akan ditampilkan kepada pengguna.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Teks Soal',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan pertanyaan...',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Teks soal wajib diisi'
                          : null,
                      enabled: !isLoading,
                      maxLines: 5,
                      minLines: 3,
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
