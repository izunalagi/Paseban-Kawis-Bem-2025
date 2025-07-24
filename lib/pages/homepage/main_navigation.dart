import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom__button_nav.dart';
import 'beranda.dart';
import 'peringkat.dart';
import 'profil.dart';
import 'chatbot_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const PeringkatPage(),
    const ChatbotPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
