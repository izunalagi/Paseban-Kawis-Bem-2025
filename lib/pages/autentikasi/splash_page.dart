import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verification_page.dart';
import 'package:another_flushbar/flushbar.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasHandledLogout = false;

  @override
  void initState() {
    super.initState();
    _checkPendingVerification();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['logout'] == true && !_hasHandledLogout) {
      _hasHandledLogout = true;
      // Tampilkan Flushbar dari atas
      Flushbar(
        message: 'Logout berhasil!',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  void _checkPendingVerification() async {
    print('[SPLASH] Cek pending verifikasi...');
    final prefs = await SharedPreferences.getInstance();
    final pendingEmail = prefs.getString('pending_verification_email');
    final pendingType = prefs.getString('pending_verification_type');
    print('[SPLASH] pendingEmail=$pendingEmail, pendingType=$pendingType');
    if (pendingEmail != null && pendingType != null) {
      print(
        '[SPLASH] Akan redirect ke halaman verifikasi karena pendingEmail=$pendingEmail, pendingType=$pendingType',
      );
      // Tampilkan splashscreen minimal 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));
      // Arahkan ke halaman verifikasi (langsung, tanpa addPostFrameCallback)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerificationPage(email: pendingEmail, type: pendingType),
        ),
      );
      return;
    }
    print('[SPLASH] Tidak ada pending verifikasi, lanjut cek session...');
    _checkSession();
  }

  Future<void> _checkSession() async {
    print('[SPLASH] Mulai cek session...');
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loggedIn = await Future.any([
        authProvider.tryAutoLogin(),
        Future.delayed(const Duration(seconds: 5)).then((_) => false),
      ]);
      print('[SPLASH] loggedIn=$loggedIn');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (loggedIn) {
        print('[SPLASH] User logged in, cek role...');
        if (authProvider.roleId == 1) {
          print('[SPLASH] Redirect ke /admin/dashboard');
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          print('[SPLASH] Redirect ke /');
          Navigator.pushReplacementNamed(context, '/');
        }
      } else if (args == null || args['logout'] != true) {
        // Hanya redirect ke login jika bukan dari logout
        print('[SPLASH] Redirect ke /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('[SPLASH] ERROR: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(image: AssetImage('assets/images/logo.png'), height: 100),
            SizedBox(height: 32),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "PASEBAN ",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryButton,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: "KAWIS",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
