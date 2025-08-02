import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom__button_nav.dart';
import '../../providers/chat_provider.dart';
import '../../providers/quiz_provider.dart';
import 'beranda.dart';
import 'peringkat.dart';
import 'profil.dart';
import 'chatbot_page.dart';

class MainNavigation extends StatefulWidget {
  final int? initialIndex;

  const MainNavigation({super.key, this.initialIndex});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  final List<Widget> _pages = [
    const HomePage(),
    const PeringkatPage(),
    const ChatbotPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
    print('DEBUG: MainNavigation initialized with index: $_selectedIndex');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => QuizProvider()),
      ],
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: _pages[_selectedIndex],
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _selectedIndex,
            onTap: (index) {
              print('DEBUG: Navigation tapped - Index: $index');
              print('DEBUG: Current selected index: $_selectedIndex');
              setState(() {
                _selectedIndex = index;
              });
              print('DEBUG: New selected index: $_selectedIndex');

              // Refresh beranda jika kembali ke index 0 (beranda)
              if (index == 0) {
                // Trigger rebuild untuk refresh nama user
                setState(() {});
              }
            },
          ),
        ),
      ),
    );
  }
}
