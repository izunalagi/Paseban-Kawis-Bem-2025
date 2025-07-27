import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../utils/constants.dart';
import 'tambah_edit_pilihan_page.dart';
import 'package:another_flushbar/flushbar.dart';

class KelolaPilihanPage extends StatefulWidget {
  final int questionId;
  final int quizId;
  final String questionText;
  const KelolaPilihanPage({
    super.key,
    required this.questionId,
    required this.quizId,
    required this.questionText,
  });

  @override
  State<KelolaPilihanPage> createState() => _KelolaPilihanPageState();
}

class _KelolaPilihanPageState extends State<KelolaPilihanPage> {
  @override
  void initState() {
    super.initState();
    // Tidak perlu fetchPilihanList, data sudah di-set dari soal
  }

  void goToEdit(Map data) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<QuizProvider>(context, listen: false),
          child: TambahEditPilihanPage(
            questionId: widget.questionId,
            quizId: widget.quizId,
            pilihan: data,
          ),
        ),
      ),
    );
    if (updated == true) {
      // Refresh data soal untuk mendapatkan pilihan yang terupdate
      final prov = Provider.of<QuizProvider>(context, listen: false);
      await prov.fetchSoalList(widget.quizId);
      prov.setPilihanListFromSoal(widget.questionId);

      Flushbar(
        message: 'Pilihan berhasil diperbarui',
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
          child: TambahEditPilihanPage(
            questionId: widget.questionId,
            quizId: widget.quizId,
          ),
        ),
      ),
    );
    if (added == true) {
      // Refresh data setelah add berhasil
      final prov = Provider.of<QuizProvider>(context, listen: false);
      await prov.fetchSoalList(widget.quizId);
      prov.setPilihanListFromSoal(widget.questionId);

      Flushbar(
        message: 'Pilihan berhasil ditambahkan',
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
          'Pilihan: ${widget.questionText}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, prov, _) {
          if (prov.isLoadingPilihan) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.errorPilihan != null) {
            return Center(child: Text(prov.errorPilihan!));
          }
          if (prov.pilihanList.isEmpty) {
            return const Center(child: Text('Belum ada pilihan'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.pilihanList.length,
            itemBuilder: (context, i) {
              final pilihan = prov.pilihanList[i];
              return Dismissible(
                key: ValueKey(pilihan['id']),
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
                      content: const Text('Yakin ingin menghapus pilihan ini?'),
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
                    final optionId = pilihan['id'];
                    if (optionId == null || optionId.toString().isEmpty) {
                      throw Exception('ID pilihan tidak valid');
                    }
                    final parsedId = int.parse(optionId.toString());
                    await prov.deletePilihan(
                      parsedId,
                      widget.questionId,
                      widget.quizId,
                    );

                    if (prov.errorPilihan != null) {
                      Flushbar(
                        message: 'Gagal hapus pilihan: ${prov.errorPilihan}',
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(Icons.error, color: Colors.white),
                      ).show(context);
                    } else {
                      // Refresh data setelah delete berhasil
                      await prov.fetchSoalList(widget.quizId);
                      prov.setPilihanListFromSoal(widget.questionId);

                      Flushbar(
                        message: 'Pilihan berhasil dihapus',
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
                      message: 'Gagal hapus pilihan: $e',
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
                  onTap: () => goToEdit(pilihan),
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
                          // Informasi pilihan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Pilihan ${pilihan['option_label']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (pilihan['is_correct'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Jawaban Benar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pilihan['option_text'] ?? '-',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
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
                            onPressed: () => goToEdit(pilihan),
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
        onPressed: goToAdd,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
