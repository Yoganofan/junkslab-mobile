import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:junkslab/helpers/preferences_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

 // 1. FUNGSI MEMBACA DATA DARI SHAREDPREFERENCES
  Future<void> _loadSavedData() async {
    final prefsHelper = PreferencesHelper();
    await prefsHelper.init(); // Pastikan SharedPreferences terinisialisasi

    setState(() {
      _nameController.text = prefsHelper.getUserName() ?? '';
      _phoneController.text = prefsHelper.getUserPhone() ?? '';
      _addressController.text = prefsHelper.getSelectedPickupLocationId()?.toString() ?? ''; 
      _addressController.text = prefsHelper.getUserAddress() ?? '';
    });
  }

  // 2. FUNGSI MENYIMPAN DATA KE SHAREDPREFERENCES
  Future<void> _saveData() async {
    setState(() => _isSaving = true);

    final prefsHelper = PreferencesHelper();
    await prefsHelper.init();

    // Simpan ke preferensi menggunakan fungsi bawaan helper Anda
    await prefsHelper.setUserName(_nameController.text);
    await prefsHelper.setUserPhone(_phoneController.text);
    await prefsHelper.setUserAddress(_addressController.text);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Color(0xFF006B23),
        ),
      );
    }
  }

  // 3. FUNGSI LOGOUT (HAPUS SESI SECARA BERSIH)
  Future<void> _handleLogout() async {
    final prefsHelper = PreferencesHelper();
    await prefsHelper.init();
    
    await prefsHelper.clearAllPreferences();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FAF5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF006B23),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3F4A3D))),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama Anda',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBECABA))),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Nomor Handphone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3F4A3D))),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '08xxxxxxxxxx',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBECABA))),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Alamat Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3F4A3D))),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat penjemputan limbah',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFBECABA))),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B23),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}