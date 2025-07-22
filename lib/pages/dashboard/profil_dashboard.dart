import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class ProfilDashboard extends StatefulWidget {
  const ProfilDashboard({super.key});

  @override
  State<ProfilDashboard> createState() => _ProfilDashboardState();
}

class _ProfilDashboardState extends State<ProfilDashboard> {
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
    // Dummy data, bisa diganti dengan data user dari provider
    final user = Provider.of<AuthProvider>(context).user;
    return Container(
      color: AppColors.backgroundLight,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              const SizedBox(height: 12),
              Text(
                user?.nama ?? 'Admin',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                user?.email ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileTile(
                icon: Icons.edit,
                iconColor: AppColors.dashboardPrimary,
                title: 'Edit Profil',
                subtitle: 'Tekan untuk edit profil',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                icon: Icons.phone_android,
                iconColor: AppColors.dashboardPrimary,
                title: 'Nomor Telepon',
                subtitle: user?.telepon ?? '-',
                showTrailing: false,
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                icon: Icons.description,
                iconColor: AppColors.dashboardPrimary,
                title: 'Syarat dan Ketentuan',
                subtitle: 'Tekan untuk melihat syarat dan ketentuan',
                onTap: () {},
              ),
              const Spacer(),
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
