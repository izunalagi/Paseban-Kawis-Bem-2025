import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF043461), Color(0xFF052f54)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Beranda',
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.emoji_events_outlined,
              activeIcon: Icons.emoji_events,
              label: 'Peringkat',
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.chat_outlined,
              activeIcon: Icons.chat,
              label: 'Chat AI',
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 24,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
      label: label,
    );
  }
}

class SimpleCustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SimpleCustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
      ),
      items: [
        _buildSimpleNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Beranda',
          index: 0,
        ),
        _buildSimpleNavItem(
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events,
          label: 'Peringkat',
          index: 1,
        ),
        _buildSimpleNavItem(
          icon: Icons.chat_outlined,
          activeIcon: Icons.chat,
          label: 'Chat AI',
          index: 2,
        ),
        _buildSimpleNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
          index: 3,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildSimpleNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(
        currentIndex == index ? activeIcon : icon,
        size: 24,
        color: currentIndex == index ? AppColors.accent : Colors.grey[600],
      ),
      label: label,
    );
  }
}
