import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../providers/auth_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/modul_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 3; // Profil sekarang di indeks 3 (paling kanan)
  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;

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

                      // Refresh nama user di beranda
                      if (mounted) {
                        // Trigger rebuild untuk refresh nama di beranda
                        setState(() {});
                      }

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
      builder: (BuildContext context) {
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
                Navigator.of(context).pop(); // Tutup dialog
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
                Navigator.of(context).pop(); // Tutup dialog
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
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Lakukan logout
      await Provider.of<AuthProvider>(context, listen: false).logout();

      // Tutup loading
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

      // Navigasi ke splash screen
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/splash',
        (route) => false, // Hapus semua route sebelumnya
      );
    } catch (e) {
      // Tutup loading
      Navigator.of(context).pop();

      // Tampilkan error dari atas
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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profil'),
      body: _loadingProfile
          ? const LoadingWidget(message: 'Memuat profil...')
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.backgroundLight],
                  stops: [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _profile?['nama'] ?? '-',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profile?['email'] ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Options Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileTile(
                            icon: Icons.edit,
                            iconColor: AppColors.accent,
                            title: 'Ubah Profil',
                            subtitle: 'Tekan untuk ubah profil',
                            onTap: _showEditProfileDialog,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileTile(
                            icon: Icons.phone_android,
                            iconColor: AppColors.accent,
                            title: 'Nomor Telepon',
                            subtitle: _profile?['telepon'] ?? '-',
                            showTrailing: false,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileTile(
                            icon: Icons.description,
                            iconColor: AppColors.accent,
                            title: 'Syarat dan Ketentuan',
                            subtitle:
                                'Tekan untuk melihat syarat dan ketentuan',
                            onTap: () {
                              // TODO: Navigate to terms page
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Logout Button Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _showLogoutDialog,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keluar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Keluar dari aplikasi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textLight,
                                  size: 20,
                                ),
                              ],
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

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
