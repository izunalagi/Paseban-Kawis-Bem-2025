import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class PanduanPage extends StatefulWidget {
  const PanduanPage({super.key});

  @override
  State<PanduanPage> createState() => _PanduanPageState();
}

class _PanduanPageState extends State<PanduanPage> {
  // State untuk expand/collapse tiap bagian
  final List<bool> _expanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        children: [
          _buildPanduanSection(
            index: 0,
            title: 'Bagian 1: Bagaimana cara menambahkan data?',
            content:
                'Untuk menambahkan data, klik tombol "Tambah" di halaman yang sesuai, isi form yang tersedia, lalu tekan "Simpan". Pastikan semua data sudah benar sebelum menyimpan.',
          ),
          const SizedBox(height: 16),
          _buildPanduanSection(
            index: 1,
            title: 'Bagian 2: Bagaimana cara mengedit data?',
            content:
                'Untuk mengedit data, klik ikon "Edit" di samping data yang ingin diubah, lakukan perubahan pada form, lalu tekan "Simpan".',
          ),
          const SizedBox(height: 16),
          _buildPanduanSection(
            index: 2,
            title: 'Bagian 3: Bagaimana cara menghapus data?',
            content:
                'Untuk menghapus data, klik ikon "Hapus" di samping data yang ingin dihapus, lalu konfirmasi penghapusan. Data yang sudah dihapus tidak dapat dikembalikan.',
          ),
        ],
      ),
    );
  }

  Widget _buildPanduanSection({
    required int index,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(
                _expanded[index] ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  _expanded[index] = !_expanded[index];
                });
              },
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _expanded[index]
                ? Container(
                    key: ValueKey('expanded_$index'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(content, style: const TextStyle(fontSize: 15)),
                  )
                : const SizedBox.shrink(key: ValueKey('collapsed')),
          ),
        ],
      ),
    );
  }
}
