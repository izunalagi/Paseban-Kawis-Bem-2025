import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/modul_provider.dart';
import '../../../providers/category_modul_provider.dart';
import '../../../utils/constants.dart';
import '../../../services/modul_service.dart';
import 'tambah_edit_modul_page.dart';
import 'package:another_flushbar/flushbar.dart';

class KelolaModulPage extends StatefulWidget {
  const KelolaModulPage({super.key});

  @override
  State<KelolaModulPage> createState() => _KelolaModulPageState();
}

class _KelolaModulPageState extends State<KelolaModulPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ModulProvider>(context, listen: false).fetchModul(),
    );
  }

  void goToEdit(Map data) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Provider.of<ModulProvider>(context, listen: false),
            ),
            ChangeNotifierProvider.value(
              value: Provider.of<CategoryModulProvider>(context, listen: false),
            ),
          ],
          child: TambahEditModulPage(modul: data),
        ),
      ),
    );
    if (updated == true) {
      Provider.of<ModulProvider>(context, listen: false).fetchModul();
      Flushbar(
        message: 'Modul berhasil diupdate',
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
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Provider.of<ModulProvider>(context, listen: false),
            ),
            ChangeNotifierProvider.value(
              value: Provider.of<CategoryModulProvider>(context, listen: false),
            ),
          ],
          child: const TambahEditModulPage(),
        ),
      ),
    );
    if (added == true) {
      Provider.of<ModulProvider>(context, listen: false).fetchModul();
      Flushbar(
        message: 'Modul berhasil ditambah',
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
        title: const Text(
          'Kelola Modul',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ModulProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return Center(child: Text(prov.error!));
          }
          if (prov.modul.isEmpty) {
            return const Center(child: Text('Belum ada modul'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.modul.length,
            itemBuilder: (context, i) {
              final m = prov.modul[i];
              return Dismissible(
                key: ValueKey(m['id']),
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
                      content: const Text(
                        'Yakin ingin menghapus modul ini? File PDF juga akan dihapus.',
                      ),
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
                  await Provider.of<ModulProvider>(
                    context,
                    listen: false,
                  ).deleteModul(m['id']);
                  Flushbar(
                    message: 'Modul berhasil dihapus',
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                    flushbarPosition: FlushbarPosition.TOP,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  ).show(context);
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
                        // Foto modul
                        if (m['foto'] != null)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  '${ModulService.baseUrl}/${m['foto']}',
                                ),
                                fit: BoxFit.cover,
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
                              Icons.image,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        const SizedBox(width: 16),
                        // Informasi modul
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['judul_modul'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Tampilkan kategori jika ada
                              if (m['category_modul'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    m['category_modul']['nama'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                m['deskripsi_modul'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
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
                          onPressed: () => goToEdit(m),
                        ),
                      ],
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
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Modul',
      ),
    );
  }
}
