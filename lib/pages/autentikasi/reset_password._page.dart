import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_back_button.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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
    _bottomController = AnimationController(
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  void _submitPassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showFlushBar("Kata sandi tidak boleh kosong.", isError: true);
      return;
    }

    if (password.length < 6) {
      _showFlushBar("Kata sandi minimal 6 karakter.", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showFlushBar("Kata sandi tidak cocok.", isError: true);
      return;
    }

    // Ambil email dari arguments
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email == null) {
      _showFlushBar("Email tidak ditemukan.", isError: true);
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).resetPassword(email, password, confirmPassword);
      Navigator.of(context).pop();
      _showFlushBar("Kata sandi berhasil diubah.", isError: false);
      // Navigasi ke login
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: toggleObscure,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _topFade,
                    child: SlideTransition(
                      position: _topSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Kata sandi baru Anda harus berbeda dari sebelumnya.\nIngat kata sandi yang telah Anda buat untuk masuk.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _bottomFade,
                    child: SlideTransition(
                      position: _bottomSlide,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Kata Sandi Baru',
                            controller: passwordController,
                            obscureText: obscurePassword,
                            toggleObscure: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          _buildTextField(
                            label: 'Konfirmasi Kata Sandi',
                            controller: confirmPasswordController,
                            obscureText: obscureConfirmPassword,
                            toggleObscure: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            label: "Ubah Kata Sandi",
                            onPressed: _submitPassword,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
