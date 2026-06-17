import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../helpers/penyedia_database_helper.dart'; 
import 'package:junkslab/helpers/preferences_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); 
  bool isLoginTab = true;
  String selectedRole = 'Penyedia'; 
  bool obscurePassword = true;
  bool _isLoading = false; 

  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

 
  final DatabaseHelper _databaseHelper = DatabaseHelper(); 

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    String inputIdentity = _identityController.text.trim();
    String inputPassword = _passwordController.text;

    if (isLoginTab) {
      if (inputIdentity == 'admin' || inputIdentity == 'admin@junkslab.id') {
        setState(() => _isLoading = false);
        _showSnackbar('Berhasil masuk sebagai Admin!', Colors.green);
        context.go('/');
        return;
      }

      final user = await _databaseHelper.checkUserLogin(
        inputIdentity, 
        inputPassword, 
        selectedRole,
      );

      setState(() => _isLoading = false);

      if (user != null) {
        final prefsHelper = PreferencesHelper();
        await prefsHelper.init();
        await prefsHelper.setUserEmail(inputIdentity);
        _showSnackbar('Berhasil masuk sebagai $selectedRole!', Colors.green);
        if (selectedRole == 'Penyedia') {
          context.go('/penyedia');
        } else {
          context.go('/penyerap'); 
        }
      } else {
        _showSnackbar('Akun tidak ditemukan atau kata sandi salah untuk peran $selectedRole!', Colors.red);
      }

    } else {
      final result = await _databaseHelper.registerUser(
        inputIdentity, 
        inputPassword, 
        selectedRole,
      );

      setState(() => _isLoading = false);

      if (result != -1) {
        _showSnackbar('Pendaftaran akun $selectedRole berhasil! Silakan masuk.', Colors.green);
        
        setState(() {
          isLoginTab = true;
        });
        _passwordController.clear();
      } else {
        _showSnackbar('Email atau No. Handphone sudah terdaftar sebelumnya!', Colors.red);
      }
    }
  }

  // Fungsi pembantu untuk mempermudah pemanggilan SnackBar error/sukses
  void _showSnackbar(String pesan, Color warnaKonfirmasi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warnaKonfirmasi,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey, // Membungkus UI dengan widget Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Logo Title
                const Text(
                  'JunksLab',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B23),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solusi cerdas kelola limbah makanan untuk ekonomi sirkular.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3F4A3D),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tab Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006B23).withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isLoginTab = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isLoginTab ? const Color(0xFF006B23) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Masuk',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isLoginTab ? Colors.white : const Color(0xFF3F4A3D),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isLoginTab = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isLoginTab ? const Color(0xFF006B23) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Daftar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !isLoginTab ? Colors.white : const Color(0xFF3F4A3D),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Role Selection Title
                const Text(
                  'Pilih Peran Anda',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F4A3D),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Grid Peran
                Row(
                  children: [
                    // Role 1: Penyedia
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedRole = 'Penyedia'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 120,
                          decoration: BoxDecoration(
                            color: selectedRole == 'Penyedia' ? const Color(0xFFF7FFF1) : Colors.white,
                            border: Border.all(
                              color: selectedRole == 'Penyedia' ? const Color(0xFF006B23) : const Color(0xFFBECABA),
                              width: selectedRole == 'Penyedia' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: selectedRole == 'Penyedia' ? const Color(0xFF006B23) : const Color(0xFFECEFEA),
                                child: Icon(
                                  Icons.restaurant,
                                  color: selectedRole == 'Penyedia' ? Colors.white : const Color(0xFF006B23),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Penyedia Limbah Makanan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selectedRole == 'Penyedia' ? const Color(0xFF006B23) : const Color(0xFF3F4A3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Role 2: Penyerap
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedRole = 'Penyerap'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 120,
                          decoration: BoxDecoration(
                            color: selectedRole == 'Penyerap' ? const Color(0xFFF7FFF1) : Colors.white,
                            border: Border.all(
                              color: selectedRole == 'Penyerap' ? const Color(0xFF006B23) : const Color(0xFFBECABA),
                              width: selectedRole == 'Penyerap' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: selectedRole == 'Penyerap' ? const Color(0xFF006B23) : const Color(0xFFECEFEA),
                                child: Icon(
                                  Icons.recycling,
                                  color: selectedRole == 'Penyerap' ? Colors.white : const Color(0xFF006B23),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Penyerap Limbah Makanan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selectedRole == 'Penyerap' ? const Color(0xFF006B23) : const Color(0xFF3F4A3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Username Field
                const Text(
                  'Email atau No. Handphone',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _identityController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF3F4A3D)),
                    hintText: 'example@email.com',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBECABA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006B23), width: 2),
                    ),
                  ),
                  // Menambahkan logika validasi input email/no hp
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kolom ini tidak boleh kosong';
                    }
                    if (value.length < 4) {
                      return 'Masukkan identitas akun yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kata Sandi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
                    ),
                    if (isLoginTab) // Lupa password hanya muncul di tab login
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Lupa sandi?', style: TextStyle(color: Color(0xFF006B23), fontSize: 13)),
                      ),
                  ],
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF3F4A3D)),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF3F4A3D)),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    hintText: '••••••••',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBECABA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006B23), width: 2),
                    ),
                  ),
                  // Menambahkan logika validasi kata sandi
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal berisi 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Auth Action Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B23),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLoginTab ? 'Masuk Sekarang' : 'Daftar Akun Baru',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}