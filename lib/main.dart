import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

// Tambahan import khusus untuk ngakalin Web & Deteksi Platform
import 'package:flutter/foundation.dart'; // Untuk mendeteksi kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'screens/admin/admin_provider.dart';
import 'helpers/shared_pref_helper.dart';
import 'screens/admin/pages/main_layout.dart';
import 'screens/penyerap/main_penyerap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SAKLAR SQLITE OTOMATIS ---
  if (kIsWeb) {
    // Jika jalan di Google Chrome (Web), pakai mesin Web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Jika jalan di Laptop/PC biasa, pakai mesin Desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // (Jika di HP Android/iOS, dia otomatis pakai sqflite bawaan)
  // ------------------------------

  await SharedPrefHelper.setLoginStatus(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminProvider()..refreshDashboard(),
        ),
      ],
      child: const JunksLabApp(),
    ),
  );
}

// ... (sisa kodingan GoRouter dan JunksLabApp ke bawah biarkan sama persis seperti sebelumnya) ...

// ATUR RUTE NAVIGASI (Mendukung Admin & Penyerap)
final GoRouter _router = GoRouter(
  initialLocation:
      '/penyerap', // << Memaksa aplikasi langsung ngebuka halaman kamu saat di-run
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainLayout()),
    GoRoute(
      path: '/penyerap',
      builder: (context, state) => const MainPenyerap(),
    ),
  ],
);

class JunksLabApp extends StatelessWidget {
  const JunksLabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          title: 'JunksLab App',
          debugShowCheckedModeBanner: false,

          // Tema Sinkron dengan Admin Provider
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            cardColor: Colors.white,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.grey[800],
          ),

          routerConfig: _router,
        );
      },
    );
  }
}
