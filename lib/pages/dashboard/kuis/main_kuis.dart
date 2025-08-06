import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import 'tambah_edit_quiz_page.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';
import 'kelola_soal_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<QuizProvider>(context, listen: false).fetchQuizList(),
    );
  }

  void goToEdit(Map data) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<QuizProvider>(context, listen: false),
          child: TambahEditQuizPage(quiz: data),
        ),
      ),
    );
    if (updated == true) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizList();
      Flushbar(
        message: 'Kuis berhasil diperbarui',
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
          child: const TambahEditQuizPage(),
        ),
      ),
    );
    if (added == true) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizList();
      Flushbar(
        message: 'Kuis berhasil ditambah',
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
        title: const Text('Kelola Kuis', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, prov, child) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return Center(child: Text(prov.error!));
          }
          if (prov.quizList.isEmpty) {
            return const Center(child: Text('Belum ada kuis'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.quizList.length,
            itemBuilder: (context, i) {
              final quiz = prov.quizList[i];
              return Dismissible(
                key: ValueKey(quiz['id']),
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
                      content: const Text('Yakin ingin menghapus kuis ini?'),
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
                    await prov.deleteQuiz(quiz['id']);

                    if (prov.error != null) {
                      Flushbar(
                        message: 'Gagal hapus kuis: ${prov.error}',
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(Icons.error, color: Colors.white),
                      ).show(context);
                    } else {
                      Flushbar(
                        message: 'Kuis berhasil dihapus',
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
                      message: 'Gagal hapus kuis: $e',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: quizProvider,
                          child: KelolaSoalPage(
                            quizId: quiz['id'],
                            quizTitle: quiz['title'] ?? '-',
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
                          // Thumbnail kuis
                          if (quiz['thumbnail'] != null &&
                              quiz['thumbnail'] != '')
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    quiz['thumbnail'].startsWith('http')
                                        ? quiz['thumbnail']
                                        : 'https://pasebankawis.himatifunej.com//${quiz['thumbnail']}',
                                  ),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    print('Error loading image: $exception');
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: AppColors.primary,
                                size: 32,
                              ),
                            ),
                          const SizedBox(width: 16),
                          // Informasi kuis
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz['title'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quiz['description'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () => goToEdit(quiz),
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
        tooltip: 'Tambah Kuis',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
