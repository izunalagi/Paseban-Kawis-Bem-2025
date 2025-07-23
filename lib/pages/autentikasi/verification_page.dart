import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_back_button.dart';
import '../../providers/auth_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPage extends StatefulWidget {
  final String? email;
  final String type; // 'register' atau 'forgot_password'

  const VerificationPage({super.key, this.email, required this.type});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late final AnimationController _topController;
  late final Animation<double> _topFade;
  late final Animation<Offset> _topSlide;

  late final AnimationController _bottomController;
  late final Animation<double> _bottomFade;
  late final Animation<Offset> _bottomSlide;

  bool _isAnimationInitialized = false;
  bool _isLoading = false;

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

    _isAnimationInitialized = true;
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  Future<void> _clearPendingVerification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_verification_email');
    await prefs.remove('pending_verification_type');
  }

  void _onVerify() async {
    String code = _codeControllers.map((e) => e.text).join();
    print("Kode Verifikasi: $code");

    if (code.length != 4) {
      _showFlushBar('Masukkan 4 digit kode OTP!', isError: true);
      return;
    }

    if (widget.email == null) {
      _showFlushBar('Email tidak ditemukan!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;
      if (widget.type == 'register') {
        result = await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).verifyOtp(widget.email!, code);
      } else {
        result = await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).verifyForgotOtp(widget.email!, code);
      }

      if (!mounted) return;

      _showFlushBar(
        widget.type == 'register'
            ? 'Verifikasi berhasil! Silakan login.'
            : 'Kode OTP terverifikasi! Silakan ubah sandi.',
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      if (widget.type == 'register') {
        await _clearPendingVerification();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: widget.email,
        );
      }
    } catch (e) {
      String errorMessage = "Verifikasi gagal!";
      if (e.toString().contains("OTP salah") ||
          e.toString().contains("invalid")) {
        errorMessage = "Kode OTP salah!";
      } else if (e.toString().contains("expired")) {
        errorMessage = "Kode OTP sudah expired!";
      } else if (e.toString().contains("Connection")) {
        errorMessage = "Tidak bisa terhubung ke server!";
      }

      _showFlushBar(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onResendCode() async {
    if (_isLoading) return;

    if (widget.email == null) {
      _showFlushBar('Email tidak ditemukan!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.type == 'register') {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).resendRegisterOtp(widget.email!);
      } else {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).forgotPassword(widget.email!);
      }

      _showFlushBar('Kode OTP telah dikirim ulang ke email.', isError: false);

      // Reset input fields
      for (var controller in _codeControllers) {
        controller.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      _showFlushBar(
        'Gagal mengirim ulang kode: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    bool shouldPop =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text(
              widget.type == 'register'
                  ? 'Jika Anda kembali, Anda perlu mendaftar ulang. Lanjutkan?'
                  : 'Kembali ke halaman sebelumnya?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () async {
                  await _clearPendingVerification();
                  if (!mounted) return;
                  Navigator.of(context).pop(true);
                },
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldPop) {
      await _clearPendingVerification();
    }

    return shouldPop;
  }

  Widget _buildCodeField(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
      ),
    );
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          width: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomBackButton(
                    onPressed: () async {
                      if (await _onWillPop()) {
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _topFade,
                    child: SlideTransition(
                      position: _topSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verifikasi Kode',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Masukkan kode yang telah dikirimkan ke\n${widget.email ?? "email Anda"}.\nJangan berikan kode kepada siapapun.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.4,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, _buildCodeField),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: TextButton(
                              onPressed: _isLoading ? null : _onResendCode,
                              child: RichText(
                                text: TextSpan(
                                  text: "Belum menerima kode? ",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLoading
                                          ? "Mengirim..."
                                          : "Kirim Ulang",
                                      style: TextStyle(
                                        color: _isLoading
                                            ? Colors.white38
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: _isLoading
                                            ? null
                                            : TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: CustomButton(
                              label: _isLoading
                                  ? "Memverifikasi..."
                                  : "Verifikasi",
                              onPressed: _isLoading ? null : _onVerify,
                            ),
                          ),
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
