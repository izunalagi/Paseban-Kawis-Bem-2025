import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../utils/constants.dart';
import 'tambah_edit_soal_page.dart';
import 'package:another_flushbar/flushbar.dart';
import 'kelola_pilihan_page.dart';

class KelolaSoalPage extends StatefulWidget {
  final int quizId;
  final String quizTitle;
  const KelolaSoalPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<KelolaSoalPage> createState() => _KelolaSoalPageState();
}

class _KelolaSoalPageState extends State<KelolaSoalPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<QuizProvider>(
        context,
        listen: false,
      ).fetchSoalList(widget.quizId),
    );
  }

  void goToEdit(Map data) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<QuizProvider>(context, listen: false),
          child: TambahEditSoalPage(quizId: widget.quizId, soal: data),
        ),
      ),
    );
    if (updated == true) {
      Provider.of<QuizProvider>(
        context,
        listen: false,
      ).fetchSoalList(widget.quizId);
      Flushbar(
        message: 'Soal berhasil diperbarui',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
    }
  }

  void goToAdd() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<QuizProvider>(context, listen: false),
          child: TambahEditSoalPage(quizId: widget.quizId),
        ),
      ),
    );
    if (added == true) {
      Provider.of<QuizProvider>(
        context,
        listen: false,
      ).fetchSoalList(widget.quizId);
      Flushbar(
        message: 'Soal berhasil ditambahkan',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Soal: ${widget.quizTitle}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, prov, _) {
          if (prov.isLoadingSoal) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.errorSoal != null) {
            return Center(child: Text(prov.errorSoal!));
          }
          if (prov.soalList.isEmpty) {
            return const Center(child: Text('Belum ada soal'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.soalList.length,
            itemBuilder: (context, i) {
              final soal = prov.soalList[i];
              return Dismissible(
                key: ValueKey(soal['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Hapus'),
                      content: const Text('Yakin ingin menghapus soal ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  try {
                    final prov = Provider.of<QuizProvider>(
                      context,
                      listen: false,
                    );
                    await prov.deleteSoal(soal['id'], widget.quizId);

                    if (prov.errorSoal != null) {
                      Flushbar(
                        message: 'Gagal hapus soal: ${prov.errorSoal}',
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(Icons.error, color: Colors.white),
                      ).show(context);
                    } else {
                      Flushbar(
                        message: 'Soal berhasil dihapus',
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                      ).show(context);
                    }
                  } catch (e) {
                    Flushbar(
                      message: 'Gagal hapus soal: $e',
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(8),
                      flushbarPosition: FlushbarPosition.TOP,
                      icon: const Icon(Icons.error, color: Colors.white),
                    ).show(context);
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    final quizProvider = Provider.of<QuizProvider>(
                      context,
                      listen: false,
                    );
                    quizProvider.setPilihanListFromSoal(soal['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: quizProvider,
                          child: KelolaPilihanPage(
                            questionId: soal['id'],
                            quizId: widget.quizId,
                            questionText: soal['question_text'] ?? '-',
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Informasi soal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Soal ${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  soal['question_text'] ?? '-',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Tampilkan jumlah pilihan jika ada
                                if (soal['options'] != null &&
                                    soal['options'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${soal['options'].length} pilihan',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            onPressed: () => goToEdit(soal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: goToAdd,
        tooltip: 'Tambah Soal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
