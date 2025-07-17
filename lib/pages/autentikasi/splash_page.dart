import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Tambahkan timeout untuk mencegah hang
      final loggedIn = await Future.any([
        authProvider.tryAutoLogin(),
        Future.delayed(const Duration(seconds: 5)).then((_) => false),
      ]);

      // Delay minimal untuk splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return; // Cek apakah widget masih mounted

      if (loggedIn) {
        if (authProvider.roleId == 1) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Jika terjadi error, langsung ke login page
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
