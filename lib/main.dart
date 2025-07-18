import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasebankawis/pages/dashboard/main_page.dart';
import 'pages/autentikasi/splash_page.dart';
import 'pages/autentikasi/login_page.dart';
import 'pages/autentikasi/register_page.dart';
import 'pages/autentikasi/verification_page.dart';
import 'pages/homepage/main_navigation.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Paseban Kawis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
        initialRoute: '/splash',
        routes: {
          '/': (context) => const MainNavigation(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/verifikasi': (context) => const VerificationPage(),
          '/admin/dashboard': (context) => const AdminDashboard(),
          '/splash': (context) => const SplashPage(),
        },
      ),
    );
  }
}
