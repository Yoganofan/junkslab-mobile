import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_impact_ring.dart';
import '../../../helpers/admin_prefs_helper.dart';
import '../admin_provider.dart';
import 'dashboard_page.dart';
import 'user_page.dart';
import 'content_page.dart';
import 'reward_page.dart';
import 'point_tracking_page.dart';
import 'queue_page.dart'; // <-- Import halaman baru

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const UserPage(),
    const ContentPage(),
    const RewardPage(),
    const PointTrackingPage(),
    const QueuePage(), // <-- Masukin ke index 5
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).cardColor;
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: bgColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: const Text(
            'JunksLab Portal',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: Drawer(
          backgroundColor: bgColor,
          child: _buildSidebarContent(bgColor, isMobile),
        ),
        body: Column(
          children: [
            _buildContentHeader(bgColor, isMobile),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: bgColor,
            child: _buildSidebarContent(bgColor, isMobile),
          ),
          Expanded(
            child: Column(
              children: [
                _buildContentHeader(bgColor, isMobile),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(Color bgColor, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Row(
            children: [
              Icon(Icons.eco, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                'JunksLab Portal',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _buildSidebarItem(0, Icons.dashboard_outlined, 'Dashboard', isMobile),
        _buildSidebarItem(1, Icons.people_outline, 'Manajemen Pengguna', isMobile),
        _buildSidebarItem(2, Icons.article_outlined, 'Manajemen Konten', isMobile),
        _buildSidebarItem(3, Icons.card_giftcard, 'Katalog Reward', isMobile),
        _buildSidebarItem(4, Icons.swap_horiz, 'Perputaran Poin', isMobile),
        _buildSidebarItem(5, Icons.low_priority, 'Antrean Penjemputan', isMobile), // <-- Menu baru
        const Spacer(),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app_outlined, color: Colors.red),
          title: const Text('Kembali ke Penyerap', style: TextStyle(color: Colors.red)),
          onTap: () {
            context.go('/penyerap');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Cek Sesi'),
          onTap: () async {
            bool statusLogin = await PrefsHelper.isLoggedIn();
            String tema = await PrefsHelper.getTheme();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status Login: $statusLogin | Tema: $tema'),
                  backgroundColor: Colors.blue[800],
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        Consumer<AdminProvider>(
          builder: (context, provider, _) {
            return SwitchListTile(
              title: const Text('Mode Gelap', style: TextStyle(fontSize: 14)),
              secondary: const Icon(Icons.dark_mode_outlined),
              activeColor: Colors.green,
              value: provider.isDarkMode,
              onChanged: (bool value) => provider.toggleTheme(),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin User',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Administrator',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        // <-- BAGIAN BARU BUAT NAMPILIN LAST SYNC -->
        Consumer<AdminProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: Row(
                children: [
                  const Icon(Icons.sync, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Terakhir sync: ${provider.lastSyncTime}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContentHeader(Color bgColor, bool isMobile) {
    String pageTitle = '';
    switch (_selectedIndex) {
      case 0:
        pageTitle = 'Dashboard';
        break;
      case 1:
        pageTitle = 'Manajemen Pengguna';
        break;
      case 2:
        pageTitle = 'Manajemen Konten';
        break;
      case 3:
        pageTitle = 'Katalog Reward';
        break;
      case 4:
        pageTitle = 'Perputaran Poin';
        break;
      case 5:
        pageTitle = 'Antrean Penjemputan'; 
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pageTitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (!isMobile)
            const Row(
              children: [
                Text(
                  'Impact Score',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(width: 12),
                CustomImpactRing(progress: 0.82, size: 36),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String label,
    bool isMobile,
  ) {
    bool isSelected = _selectedIndex == index;
    Color? textColor = isSelected
        ? Colors.green
        : Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, color: isSelected ? Colors.green : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.green.withOpacity(0.1),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (isMobile && Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
    );
  }
}