import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/shared_pref_helper.dart';
import '../admin/admin_provider.dart';
import '../auth/login_screen.dart';

class ProfilPenyerap extends StatefulWidget {
  const ProfilPenyerap({Key? key}) : super(key: key);

  @override
  State<ProfilPenyerap> createState() => _ProfilPenyerapState();
}

class _ProfilPenyerapState extends State<ProfilPenyerap> {
  String _userName = "Memuat...";
  bool _isDarkMode = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // MENGAMBIL DATA DARI SHARED PREFERENCE
  Future<void> _loadProfileData() async {
    String? name = await SharedPrefHelper.getUserName();
    bool theme = await SharedPrefHelper.getThemeMode();
    setState(() {
      _userName = name ?? "Yoga Nofan"; // Default name
      _isDarkMode = theme;
      _nameController.text = _userName;
    });
  }

  // MENYIMPAN DATA KE SHARED PREFERENCE (UPDATE)
  Future<void> _saveName(String newName) async {
    await SharedPrefHelper.setUserName(newName);
    setState(() {
      _userName = newName;
      _nameController.text = newName;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF0F7A44),
      ),
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Nama', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Masukkan nama baru',
            filled: true,
            fillColor: const Color(0xFFF4F7F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F7A44), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _saveName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF0F7A44), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari JunksLab?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: const Text('Kamu harus login kembali untuk mengakses aplikasi.', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              await SharedPrefHelper.setLoginStatus(false);
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PROFILE HEADER ---
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // --- MENU SECTIONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Akun Section
                  _buildSectionTitle('Akun'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _buildMenuItem(Icons.person_outline_rounded, 'Ubah Nama', onTap: _showEditNameDialog),
                    _buildMenuItem(Icons.email_outlined, 'Email', subtitle: 'yoga@junkslab.id'),
                    _buildMenuItem(Icons.phone_outlined, 'No. Telepon', subtitle: '+62 812-XXXX-XXXX'),
                  ]),
                  const SizedBox(height: 24),

                  // Preferensi Section
                  _buildSectionTitle('Preferensi'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _buildToggleItem(
                      Icons.dark_mode_outlined,
                      'Mode Gelap',
                      _isDarkMode,
                      (value) async {
                        await context.read<AdminProvider>().toggleTheme(value);
                        setState(() => _isDarkMode = value);
                      },
                    ),
                    _buildMenuItem(Icons.notifications_outlined, 'Notifikasi', subtitle: 'Aktif'),
                    _buildMenuItem(Icons.language_outlined, 'Bahasa', subtitle: 'Indonesia'),
                  ]),
                  const SizedBox(height: 24),

                  // Lainnya Section
                  _buildSectionTitle('Lainnya'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _buildMenuItem(Icons.help_outline_rounded, 'Bantuan & FAQ'),
                    _buildMenuItem(Icons.info_outline_rounded, 'Tentang Aplikasi', subtitle: 'v1.0.0'),
                    _buildMenuItem(Icons.star_outline_rounded, 'Beri Rating'),
                  ]),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _showLogoutDialog,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Keluar dari Akun',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5C32), Color(0xFF0F7A44), Color(0xFF14A05A)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F7A44).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${_userName.replaceAll(' ', '+')}&background=E8F5E9&color=2E7D32&size=256',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Fitur ganti foto segera hadir!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0F7A44), size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.recycling_rounded, color: Colors.white.withValues(alpha: 0.9), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Penyerap Limbah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title — Segera hadir!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: const Color(0xFF333333),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF0F7A44), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0F7A44), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0F7A44),
          ),
        ],
      ),
    );
  }
}