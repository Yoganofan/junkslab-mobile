import 'package:flutter/material.dart';
import '../../helpers/shared_pref_helper.dart';
import '../auth/login_screen.dart'; // Sesuaikan path jika berbeda

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
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil Penyerap', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          // Form Edit Nama
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Ubah Nama',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            ),
            onSubmitted: (value) => _saveName(value),
          ),
          const SizedBox(height: 24),
          
          // Toggle Setting (Key ke-2)
          SwitchListTile(
            title: const Text('Mode Gelap (Dark Mode)'),
            activeColor: Colors.green,
            value: _isDarkMode,
            onChanged: (bool value) async {
              await SharedPrefHelper.setThemeMode(value);
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await SharedPrefHelper.setLoginStatus(false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}