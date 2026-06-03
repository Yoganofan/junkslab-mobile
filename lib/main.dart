import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// FIX PATH: Menyesuaikan dengan struktur folder baru
import 'screens/admin/admin_provider.dart';
import 'helpers/shared_pref_helper.dart'; // Menggunakan shared pref helper kita
import 'screens/admin/pages/main_layout.dart';

// IMPORT HALAMAN PENYERAP KAMU
import 'screens/penyerap/main_penyerap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Set default status login untuk keperluan testing lokal
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
