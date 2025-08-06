import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';

class TambahEditPilihanPage extends StatefulWidget {
  final int questionId;
  final int quizId;
  final Map? pilihan;
  const TambahEditPilihanPage({
    super.key,
    required this.questionId,
    required this.quizId,
    this.pilihan,
  });

  @override
  State<TambahEditPilihanPage> createState() => _TambahEditPilihanPageState();
}

class _TambahEditPilihanPageState extends State<TambahEditPilihanPage> {
  final _formKey = GlobalKey<FormState>();
  final _optionTextController = TextEditingController();
  String? _optionLabel;
  bool _isCorrect = false;
  bool _isLoading = false;
  List<String> _existingLabels = [];
  bool _hasCorrectAnswer = false;

  @override
  void initState() {
    super.initState();

    // Gunakan post frame callback untuk memastikan widget sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pilihan != null) {
        setState(() {
          _optionLabel = widget.pilihan!['option_label'];
          _optionTextController.text = widget.pilihan!['option_text'] ?? '';

          // Debug print untuk melihat nilai is_correct
          print(
            'DEBUG: widget.pilihan![\'is_correct\'] = ${widget.pilihan!['is_correct']}',
          );
          print(
            'DEBUG: widget.pilihan![\'is_correct\'] type = ${widget.pilihan!['is_correct'].runtimeType}',
          );

          // Normalisasi nilai is_correct dengan lebih robust
          final isCorrectValue = widget.pilihan!['is_correct'];
          print('DEBUG: isCorrectValue = $isCorrectValue');

          if (isCorrectValue == true ||
              isCorrectValue == 1 ||
              isCorrectValue == '1' ||
              isCorrectValue == 'true') {
            _isCorrect = true;
            print('DEBUG: Set _isCorrect = true');
          } else if (isCorrectValue == false ||
              isCorrectValue == 0 ||
              isCorrectValue == '0' ||
              isCorrectValue == 'false') {
            _isCorrect = false;
            print('DEBUG: Set _isCorrect = false');
          } else {
            // Default ke false jika tidak dikenali
            _isCorrect = false;
            print('DEBUG: Set _isCorrect = false (default)');
          }
          print('DEBUG: Final _isCorrect = $_isCorrect');
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingLabels();
  }

  @override
  void dispose() {
    _optionTextController.dispose();
    super.dispose();
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

  void _loadExistingLabels() {
    print('DEBUG: _loadExistingLabels() called');
    print('DEBUG: _isCorrect before _loadExistingLabels = $_isCorrect');

    final prov = Provider.of<QuizProvider>(context, listen: false);
    final soalList = prov.soalList;
    final currentSoal = soalList.firstWhere(
      (soal) => soal['id'] == widget.questionId,
      orElse: () => {},
    );

    if (currentSoal.isNotEmpty && currentSoal['options'] != null) {
      final options = currentSoal['options'] as List;
      _existingLabels = options
          .map((option) => option['option_label'] as String)
          .toList();

      // Cek apakah sudah ada jawaban benar
      _hasCorrectAnswer = options.any((option) {
        final isCorrectValue = option['is_correct'];
        return isCorrectValue == true ||
            isCorrectValue == 1 ||
            isCorrectValue == '1';
      });

      // Jika sedang edit, hapus label yang sedang diedit dari daftar existing
      if (widget.pilihan != null) {
        _existingLabels.remove(widget.pilihan!['option_label']);
        // Jika sedang edit option yang benar, maka tidak ada jawaban benar lain
        final currentIsCorrect = widget.pilihan!['is_correct'];
        if (currentIsCorrect == true ||
            currentIsCorrect == 1 ||
            currentIsCorrect == '1') {
          _hasCorrectAnswer = false;
        }
      }
    }

    print('DEBUG: _isCorrect after _loadExistingLabels = $_isCorrect');
    print('DEBUG: _hasCorrectAnswer = $_hasCorrectAnswer');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showFlushBar('Semua field wajib diisi', isError: true);
      return;
    }

    // Validasi tambahan untuk jawaban benar
    if (_isCorrect && _hasCorrectAnswer) {
      // Jika sedang edit dan option yang sedang diedit bukan jawaban benar
      if (widget.pilihan != null) {
        final currentIsCorrect = widget.pilihan!['is_correct'];
        final isCurrentCorrect =
            currentIsCorrect == true ||
            currentIsCorrect == 1 ||
            currentIsCorrect == '1';

        if (!isCurrentCorrect) {
          _showFlushBar(
            'Hanya boleh ada satu jawaban benar per soal!',
            isError: true,
          );
          return;
        }
      } else {
        // Jika sedang tambah baru
        _showFlushBar(
          'Hanya boleh ada satu jawaban benar per soal!',
          isError: true,
        );
        return;
      }
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      final prov = Provider.of<QuizProvider>(context, listen: false);
      if (widget.pilihan == null) {
        await prov.addPilihan(
          questionId: widget.questionId,
          quizId: widget.quizId,
          optionLabel: _optionLabel!,
          optionText: _optionTextController.text,
          isCorrect: _isCorrect,
        );
      } else {
        final optionId = widget.pilihan!['id'];
        if (optionId == null || optionId.toString().isEmpty) {
          throw Exception('ID pilihan tidak valid');
        }
        final parsedOptionId = int.parse(optionId.toString());
        await prov.editPilihan(
          optionId: parsedOptionId,
          questionId: widget.questionId,
          quizId: widget.quizId,
          optionLabel: _optionLabel!,
          optionText: _optionTextController.text,
          isCorrect: _isCorrect,
        );
      }
      if (prov.errorPilihan != null) throw prov.errorPilihan!;
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      print('DEBUG ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan pilihan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.pilihan == null ? 'Tambah Pilihan' : 'Ubah Pilihan',
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
              // Label Pilihan
              const Text(
                'Label Pilihan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih label untuk pilihan ini (A, B, C, atau D).',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
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
                child: DropdownButtonFormField<String>(
                  value: _optionLabel,
                  items: ['A', 'B', 'C', 'D']
                      .where((label) => !_existingLabels.contains(label))
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Label Pilihan',
                    border: OutlineInputBorder(),
                    hintText: 'Pilih label...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Label wajib dipilih';
                    }
                    if (_existingLabels.contains(v)) {
                      return 'Label $v sudah digunakan';
                    }
                    return null;
                  },
                  onChanged: (v) => setState(() => _optionLabel = v),
                  onSaved: (v) => _optionLabel = v,
                ),
              ),
              const SizedBox(height: 24),

              // Teks Pilihan
              const Text(
                'Teks Pilihan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan teks pilihan yang akan ditampilkan kepada pengguna.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
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
                  controller: _optionTextController,
                  decoration: const InputDecoration(
                    labelText: 'Teks Pilihan',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan teks pilihan...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Teks pilihan wajib diisi'
                      : null,
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(height: 16),
              // Status jawaban benar
              const Text(
                'Status Jawaban',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tentukan apakah pilihan ini adalah jawaban benar.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCorrect ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _isCorrect ? Colors.green : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect
                          ? 'Pilihan ini adalah jawaban benar'
                          : 'Pilihan ini bukan jawaban benar',
                      style: TextStyle(
                        color: _isCorrect ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle button untuk mengubah status jawaban benar
              if (widget.pilihan == null || !_hasCorrectAnswer) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCorrect = !_isCorrect;
                      });
                    },
                    icon: Icon(
                      _isCorrect
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isCorrect
                          ? 'Hapus sebagai jawaban benar'
                          : 'Jadikan sebagai jawaban benar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCorrect
                          ? Colors.red
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sudah ada jawaban benar untuk soal ini. Tidak bisa menambah jawaban benar baru.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        widget.pilihan == null
                            ? 'Tambah Pilihan'
                            : 'Simpan Perubahan',
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
