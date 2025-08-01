import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'pages/autentikasi/splash_page.dart';
import 'pages/autentikasi/login_page.dart';
import 'pages/autentikasi/register_page.dart';
import 'pages/homepage/main_navigation.dart';
import 'providers/auth_provider.dart';
import 'pages/autentikasi/reset_password._page.dart';
import 'pages/dashboard/main_navigation_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations untuk mendukung fullscreen video
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
          // Tambahkan theme untuk mendukung YouTube player
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => const MainNavigation(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/admin/dashboard': (context) => const MainNavigationDashboard(),
          '/splash': (context) => const SplashPage(),
          '/reset-password': (context) => const ResetPasswordPage(),
        },
      ),
    );
  }
}
