import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/modul_service.dart';

class ProfilDashboard extends StatefulWidget {
  const ProfilDashboard({super.key});

  @override
  State<ProfilDashboard> createState() => _ProfilDashboardState();
}

class _ProfilDashboardState extends State<ProfilDashboard> {
  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;
  // Tambahkan state untuk expand/collapse syarat & ketentuan
  bool _showSyarat = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final data = await UserService().getProfile();
      setState(() {
        _profile = data;
        _loadingProfile = false;
      });
    } catch (e) {
      setState(() => _loadingProfile = false);
      Flushbar(
        message: 'Gagal mengambil profil: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  void _showEditProfileDialog() {
    final namaController = TextEditingController(text: _profile?['nama'] ?? '');
    final emailController = TextEditingController(
      text: _profile?['email'] ?? '',
    );
    final teleponController = TextEditingController(
      text: _profile?['telepon'] ?? '',
    );
    File? selectedImage;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              print('Icon kamera ditekan');
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
              );
              print('Picked: ${picked?.path}');
              if (picked != null) {
                setState(() {
                  selectedImage = File(picked.path);
                });
              }
            }

            String? fotoUrl = _profile?['foto'];
            if (fotoUrl != null &&
                fotoUrl.isNotEmpty &&
                !fotoUrl.startsWith('http')) {
              fotoUrl = '${ModulService.baseUrl}/$fotoUrl';
            }

            return AlertDialog(
              title: const Text('Edit Profil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (fotoUrl != null && fotoUrl.isNotEmpty
                                        ? NetworkImage(fotoUrl)
                                        : null)
                                    as ImageProvider?,
                          child:
                              (selectedImage == null &&
                                  (fotoUrl == null || fotoUrl.isEmpty))
                              ? const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: teleponController,
                      decoration: const InputDecoration(labelText: 'Telepon'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      Navigator.of(context).pop();
                      await UserService().updateProfile(
                        nama: namaController.text,
                        email: emailController.text,
                        telepon: teleponController.text,
                        fotoPath: selectedImage?.path,
                      );
                      await _fetchProfile();
                      Flushbar(
                        message: 'Profil berhasil diupdate',
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                    } catch (e) {
                      Flushbar(
                        message: 'Gagal update profil: $e',
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      await Provider.of<AuthProvider>(context, listen: false).logout();
      Navigator.of(context).pop();
      // Tampilkan notifikasi sukses dari atas
      Flushbar(
        message: 'Logout berhasil!',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
      }
    } catch (e) {
      Navigator.of(context).pop();
      Flushbar(
        message: 'Logout gagal: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? fotoUrl = _profile?['foto'];
    if (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.startsWith('http')) {
      fotoUrl = '${ModulService.baseUrl}/$fotoUrl';
    }
    return Container(
      color: AppColors.backgroundLight,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loadingProfile
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (fotoUrl != null && fotoUrl.isNotEmpty)
                              ? NetworkImage(fotoUrl)
                              : null,
                          child: (fotoUrl == null || fotoUrl.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _profile?['nama'] ?? '-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _profile?['email'] ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileTile(
                        icon: Icons.edit,
                        iconColor: AppColors.dashboardPrimary,
                        title: 'Edit Profil',
                        subtitle: 'Tekan untuk edit profil',
                        onTap: _showEditProfileDialog,
                      ),
                      const SizedBox(height: 8),
                      _buildProfileTile(
                        icon: Icons.phone_android,
                        iconColor: AppColors.dashboardPrimary,
                        title: 'Nomor Telepon',
                        subtitle: _profile?['telepon'] ?? '-',
                        showTrailing: false,
                      ),
                      const SizedBox(height: 8),
                      _buildProfileTile(
                        icon: Icons.description,
                        iconColor: AppColors.dashboardPrimary,
                        title: 'Syarat dan Ketentuan',
                        subtitle: 'Tekan untuk melihat syarat dan ketentuan',
                        onTap: () {
                          setState(() {
                            _showSyarat = !_showSyarat;
                          });
                        },
                      ),
                      Visibility(
                        visible: _showSyarat,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            padding: const EdgeInsets.all(16),
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
                            child: Text(
                              'Syarat & Ketentuan Penggunaan Aplikasi:\n\n'
                              '1. Aplikasi ini dikembangkan oleh BEM Fasilkom Universitas Jember dalam rangka program PPK Ormawa untuk mendukung digitalisasi dan pelayanan di desa.\n\n'
                              '2. Aplikasi diberikan secara gratis kepada desa dan hanya boleh digunakan untuk keperluan administrasi, edukasi, dan pelayanan masyarakat desa.\n\n'
                              '3. Pengelolaan akun dan data pengguna menjadi tanggung jawab pihak desa.\n\n'
                              '4. Data yang diinput harus benar dan dapat dipertanggungjawabkan.\n\n'
                              '5. Dilarang menggunakan aplikasi untuk aktivitas yang melanggar hukum atau merugikan pihak lain.\n\n'
                              '6. BEM Fasilkom Universitas Jember tidak bertanggung jawab atas penyalahgunaan aplikasi di luar tujuan awal pengembangan.\n\n'
                              '7. Pengembangan dan pemeliharaan aplikasi dapat dilanjutkan oleh pihak desa atau kolaborator lain setelah serah terima.\n\n'
                              '8. Hak cipta aplikasi tetap dimiliki oleh pengembang, namun desa diberikan hak penuh untuk menggunakan dan mengembangkan lebih lanjut.\n\n'
                              '9. Segala bentuk kerjasama, pengembangan, atau distribusi ulang aplikasi harus sepengetahuan BEM Fasilkom Universitas Jember.\n\n'
                              'Terima kasih telah menggunakan aplikasi ini. Semoga dapat bermanfaat untuk kemajuan desa dan masyarakat.',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Keluar',
                          onPressed: _showLogoutDialog,
                          backgroundColor: AppColors.dashboardPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showTrailing)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
