import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_back_button.dart';
import '../../providers/auth_provider.dart';
import 'verification_page.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();

  late final AnimationController _topController;
  late final AnimationController _bottomController;
  late final Animation<double> _topFade;
  late final Animation<Offset> _topSlide;
  late final Animation<double> _bottomFade;
  late final Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _topController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _topFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _topController, curve: Curves.easeIn));
    _topSlide = Tween(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _topController, curve: Curves.easeOut));

    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bottomFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bottomController, curve: Curves.easeIn));
    _bottomSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );

    _topController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bottomController.forward();
    });
  }

  @override
  void dispose() {
    _topController.dispose();
    _bottomController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _submitEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showFlushBar("Email tidak boleh kosong!", isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showFlushBar("Format email tidak valid!", isError: true);
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      // Panggil endpoint forgot password
      final provider = Provider.of<AuthProvider>(context, listen: false);
      // Buat fungsi di provider jika belum ada
      await provider.forgotPassword(email);
      Navigator.of(context).pop();
      _showFlushBar("Kode verifikasi telah dikirim.", isError: false);
      // Navigasi ke halaman verifikasi OTP lupa password
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerificationPage(email: email, type: 'forgot_password'),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showFlushBar(
        e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    }
  }

  void _showFlushBar(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomBackButton(),
                const SizedBox(height: 40),

                // Top Animated Title + Subtitle
                FadeTransition(
                  opacity: _topFade,
                  child: SlideTransition(
                    position: _topSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lupa Kata Sandi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Masukkan email terdaftar untuk menerima kode verifikasi.\nKode verifikasi hanya berlaku selama 5 menit.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Bottom Animated Form + Button
                FadeTransition(
                  opacity: _bottomFade,
                  child: SlideTransition(
                    position: _bottomSlide,
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomButton(label: "Kirim", onPressed: _submitEmail),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
