import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'main_page.dart';
import 'panduan/panduan_page.dart';
import 'profil_dashboard.dart';
import '../../providers/quiz_provider.dart';
import 'package:provider/provider.dart';
// TODO: import halaman Panduan dan Profil jika sudah ada

class MainNavigationDashboard extends StatefulWidget {
  const MainNavigationDashboard({super.key});

  @override
  State<MainNavigationDashboard> createState() =>
      _MainNavigationDashboardState();
}

class _MainNavigationDashboardState extends State<MainNavigationDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const AdminDashboard(),
    const PanduanPage(),
    const ProfilDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.dashboardPrimary,
            elevation: 0,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: CustomBottomNavDashboard(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: AppColors.dashboardPrimary,
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavDashboard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  const CustomBottomNavDashboard({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: backgroundColor ?? AppColors.dashboardPrimary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Panduan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
