import 'package:flutter/material.dart';
import 'dashboard_penyerap.dart';
import 'marketplace_screen.dart';
import 'profil_penyerap.dart';
import 'history_screen.dart';

class MainPenyerap extends StatefulWidget {
  const MainPenyerap({Key? key}) : super(key: key);

  // Global key to allow child widgets to switch tabs
  static final GlobalKey<_MainPenyerapState> mainKey = GlobalKey<_MainPenyerapState>();

  @override
  State<MainPenyerap> createState() => _MainPenyerapState();
}

class _MainPenyerapState extends State<MainPenyerap> {
  int _selectedIndex = 0;

  /// Public method so children can trigger tab switches
  void navigateToTab(int index) {
    if (index >= 0 && index < 4) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build pages with callbacks for tab navigation
    final List<Widget> pages = [
      DashboardPenyerap(onNavigateToTab: navigateToTab),
      MarketplaceScreen(onNavigateToTab: navigateToTab),
      const HistoryScreen(),
      const ProfilPenyerap(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: navigateToTab,
          selectedItemColor: const Color(0xFF0F7A44),
          unselectedItemColor: const Color(0xFFAAAAAA),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Dashboard', 0),
            _buildNavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Marketplace', 1),
            _buildNavItem(Icons.history_outlined, Icons.history_rounded, 'Riwayat', 2),
            _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 4, top: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: isSelected ? 26 : 24,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F7A44),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
      label: label,
    );
  }
}
