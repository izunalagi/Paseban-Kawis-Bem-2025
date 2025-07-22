import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'login_page.dart';
import 'verification_page.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscurePassword = true;

  late final AnimationController _topController;
  late final Animation<double> _topFade;
  late final Animation<Offset> _topSlide;

  late final AnimationController _formController;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  bool _isAnimationInitialized = false;

  @override
  void initState() {
    super.initState();

    _topController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _topFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _topController, curve: Curves.easeIn));
    _topSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _topController, curve: Curves.easeOut));

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeIn));
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    _topController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formController.forward();
    });

    _isAnimationInitialized = true;
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    _topController.dispose();
    _formController.dispose();
    super.dispose();
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
    if (!_isAnimationInitialized) return const SizedBox();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Column(
              children: [
                // Logo dan teks atas
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: FadeTransition(
                    opacity: _topFade,
                    child: SlideTransition(
                      position: _topSlide,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/logo.png', height: 85),
                          const SizedBox(height: 52),
                          const Text(
                            'Mari Memulai\nPerjalanan Bersama Kami!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form
                Expanded(
                  child: FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: _formSlide,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Daftar",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: "Nama",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                decoration: InputDecoration(
                                  labelText: "Kata Sandi",
                                  labelStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: const UnderlineInputBorder(),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: "Nomor Telepon",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                label: "Register",
                                onPressed: () async {
                                  // Validasi input
                                  if (emailController.text.trim().isEmpty) {
                                    _showFlushBar(
                                      'Email tidak boleh kosong!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  if (nameController.text.trim().isEmpty) {
                                    _showFlushBar(
                                      'Nama tidak boleh kosong!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  if (passwordController.text.isEmpty) {
                                    _showFlushBar(
                                      'Password tidak boleh kosong!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  if (phoneController.text.trim().isEmpty) {
                                    _showFlushBar(
                                      'Nomor telepon tidak boleh kosong!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  if (passwordController.text.length < 6) {
                                    _showFlushBar(
                                      'Password minimal 6 karakter!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  try {
                                    // Tampilkan loading
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );

                                    // Lakukan register
                                    await Provider.of<AuthProvider>(
                                      context,
                                      listen: false,
                                    ).register(
                                      nameController.text.trim(),
                                      emailController.text.trim(),
                                      passwordController.text,
                                      phoneController.text.trim(),
                                    );

                                    // Tutup loading
                                    Navigator.of(context).pop();

                                    // Tampilkan notifikasi sukses
                                    _showFlushBar(
                                      'Registrasi berhasil! OTP dikirim ke email.',
                                      isError: false,
                                    );

                                    // Delay agar pesan sukses bisa terbaca user
                                    await Future.delayed(
                                      const Duration(milliseconds: 1500),
                                    );

                                    // Simpan status pending verifikasi ke SharedPreferences
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'pending_verification_email',
                                      emailController.text.trim(),
                                    );
                                    await prefs.setString(
                                      'pending_verification_type',
                                      'register',
                                    );

                                    // Navigasi ke halaman verifikasi dengan data email
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerificationPage(
                                          email: emailController.text.trim(),
                                          type: 'register',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Tutup loading
                                    Navigator.of(context).pop();

                                    // Tampilkan error
                                    String errorMessage = "Registrasi gagal!";
                                    if (e.toString().contains(
                                      "Email sudah terdaftar",
                                    )) {
                                      errorMessage = "Email sudah terdaftar!";
                                    } else if (e.toString().contains(
                                      "Connection",
                                    )) {
                                      errorMessage =
                                          "Tidak bisa terhubung ke server!";
                                    }

                                    _showFlushBar(errorMessage, isError: true);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: Duration.zero,
                                        pageBuilder: (_, __, ___) =>
                                            const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text.rich(
                                    TextSpan(
                                      text: 'Sudah memiliki akun? ',
                                      style: TextStyle(color: Colors.black54),
                                      children: [
                                        TextSpan(
                                          text: 'Login',
                                          style: TextStyle(
                                            color: AppColors.primaryButton,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
