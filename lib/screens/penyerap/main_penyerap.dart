import 'package:flutter/material.dart';
import 'dashboard_penyerap.dart';
import 'marketplace_screen.dart'; 
import 'profil_penyerap.dart';    

class MainPenyerap extends StatefulWidget {
  const MainPenyerap({Key? key}) : super(key: key);

  @override
  State<MainPenyerap> createState() => _MainPenyerapState();
}

class _MainPenyerapState extends State<MainPenyerap> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditukar-tukar pada Bottom Navigation Bar
  final List<Widget> _pages = [
    const DashboardPenyerap(),
    const MarketplaceScreen(), 
    const Center(child: Text('Halaman History (Segera Hadir)')), // Ini nanti kita buat
    const ProfilPenyerap(),      
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home), 
            label: 'Dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined), 
            activeIcon: Icon(Icons.storefront), 
            label: 'Marketplace'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), 
            activeIcon: Icon(Icons.history), 
            label: 'History'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}