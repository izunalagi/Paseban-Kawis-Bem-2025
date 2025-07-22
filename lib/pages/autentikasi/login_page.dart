import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

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
      if (mounted) {
        _formController.forward();
      }
    });

    _isAnimationInitialized = true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
      flushbarPosition: FlushbarPosition.TOP, // muncul dari atas
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
    ).show(context);
  }

  bool _validateInputs() {
    // Validasi email kosong
    if (emailController.text.trim().isEmpty) {
      _showFlushBar('Email tidak boleh kosong!', isError: true);
      return false;
    }

    // Validasi password kosong
    if (passwordController.text.isEmpty) {
      _showFlushBar('Password tidak boleh kosong!', isError: true);
      return false;
    }

    // Validasi format email - FIXED REGEX
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(emailController.text.trim())) {
      _showFlushBar('Format email tidak valid!', isError: true);
      return false;
    }

    return true;
  }

  void _performLogin() async {
    // Validasi input
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("🔄 Mencoba login dengan email: " + emailController.text);

      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(emailController.text.trim(), passwordController.text);

      print("✅ Login berhasil!");
      _showFlushBar('Login berhasil!');

      final roleId = Provider.of<AuthProvider>(context, listen: false).roleId;

      print("👤 Role ID: $roleId");

      // Delay sebentar agar user lihat notifikasi sukses
      await Future.delayed(const Duration(seconds: 1));

      if (roleId == 1) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print("❌ Login error: $e");

      String errorMessage = "Login gagal!";
      if (e.toString().contains("EMAIL_NOT_VERIFIED")) {
        errorMessage = "Akun belum diverifikasi!";
        _showFlushBar(errorMessage, isError: true);
        // Simpan pending verifikasi agar splash bisa redirect
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'pending_verification_email',
          emailController.text.trim(),
        );
        await prefs.setString('pending_verification_type', 'register');
        // Delay agar user baca pesan
        await Future.delayed(const Duration(milliseconds: 1500));
        // Redirect ke halaman verifikasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              email: emailController.text.trim(),
              type: 'register',
            ),
          ),
        );
        return;
      } else if (e.toString().contains("401")) {
        errorMessage = "Email atau password salah!";
      } else if (e.toString().contains("Connection")) {
        errorMessage = "Tidak bisa terhubung ke server!";
      } else if (e.toString().contains("timeout")) {
        errorMessage = "Koneksi timeout!";
      } else if (e.toString().contains("SocketException")) {
        errorMessage = "Tidak bisa terhubung ke server!";
      }

      _showFlushBar(errorMessage, isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Column(
              children: [
                // Bagian atas dengan animasi logo dan teks
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
                            'Selamat Datang,\nSilahkan Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bagian form login dengan animasi
                Expanded(
                  child: FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: _formSlide,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Login",
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
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
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
                                labelStyle: const TextStyle(color: Colors.grey),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
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
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Lupa Kata Sandi?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              label: isLoading ? "Loading..." : "Login",
                              onPressed: isLoading
                                  ? () {}
                                  : () => _performLogin(),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    text: 'Belum memiliki Akun? ',
                                    style: TextStyle(color: Colors.black54),
                                    children: [
                                      TextSpan(
                                        text: 'Daftar Sekarang',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
