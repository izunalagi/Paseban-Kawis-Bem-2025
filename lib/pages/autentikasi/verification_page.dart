import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_back_button.dart';
import '../../providers/auth_provider.dart';

class VerificationPage extends StatefulWidget {
  final String? email;

  const VerificationPage({super.key, this.email});

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

  void _onVerify() async {
    String code = _codeControllers.map((e) => e.text).join();
    print("Kode Verifikasi: $code");

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 4 digit kode OTP!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak ditemukan!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Verifikasi OTP
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).verifyOtp(widget.email!, code);

      // Tutup loading
      Navigator.of(context).pop();

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigasi ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Tutup loading
      Navigator.of(context).pop();

      // Tampilkan error
      String errorMessage = "Verifikasi gagal!";
      if (e.toString().contains("OTP salah")) {
        errorMessage = "Kode OTP salah!";
      } else if (e.toString().contains("expired")) {
        errorMessage = "Kode OTP sudah expired!";
      } else if (e.toString().contains("Connection")) {
        errorMessage = "Tidak bisa terhubung ke server!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onResendCode() {
    print("Kirim ulang kode");
    // TODO: Implement resend code logic
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

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                          'Verifikasi Kode',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Masukkan kode yang telah dikirimkan melalui email.\nJangan berikan kode kepada siapapun.',
                          style: TextStyle(
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
                            onPressed: _onResendCode,
                            child: RichText(
                              text: const TextSpan(
                                text: "Belum menerima kode? ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Kirim Ulang",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
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
                            label: "Verifikasi",
                            onPressed: _onVerify,
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
    );
  }
}
