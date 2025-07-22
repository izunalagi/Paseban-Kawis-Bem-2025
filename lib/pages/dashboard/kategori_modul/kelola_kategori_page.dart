import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/category_modul_provider.dart';
import 'tambah_edit_kategori_page.dart';
import '../../../utils/constants.dart';
import 'package:another_flushbar/flushbar.dart';

class KelolaKategoriPage extends StatefulWidget {
  const KelolaKategoriPage({super.key});

  @override
  State<KelolaKategoriPage> createState() => _KelolaKategoriPageState();
}

class _KelolaKategoriPageState extends State<KelolaKategoriPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CategoryModulProvider>(
        context,
        listen: false,
      ).fetchKategori(),
    );
  }

  void goToEdit(Map data) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<CategoryModulProvider>(context, listen: false),
          child: TambahEditKategoriPage(kategori: data),
        ),
      ),
    );
    if (updated == true) {
      Provider.of<CategoryModulProvider>(
        context,
        listen: false,
      ).fetchKategori();
      Flushbar(
        message: 'Kategori berhasil diupdate',
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
          value: Provider.of<CategoryModulProvider>(context, listen: false),
          child: const TambahEditKategoriPage(),
        ),
      ),
    );
    if (added == true) {
      Provider.of<CategoryModulProvider>(
        context,
        listen: false,
      ).fetchKategori();
      Flushbar(
        message: 'Kategori berhasil ditambah',
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
          'Kelola Kategori',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CategoryModulProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return Center(child: Text(prov.error!));
          }
          if (prov.kategori.isEmpty) {
            return const Center(child: Text('Belum ada kategori'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.kategori.length,
            itemBuilder: (context, i) {
              final k = prov.kategori[i];
              return Dismissible(
                key: ValueKey(k['id']),
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
                        'Yakin ingin menghapus kategori ini? Semua modul terkait juga akan dihapus.',
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
                  await Provider.of<CategoryModulProvider>(
                    context,
                    listen: false,
                  ).deleteKategori(k['id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kategori berhasil dihapus'),
                      backgroundColor: Colors.green,
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Text(
                      k['nama'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => goToEdit(k),
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
        tooltip: 'Tambah Kategori',
      ),
    );
  }
}
