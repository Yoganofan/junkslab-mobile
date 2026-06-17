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
import 'screens/penyedia/main_navigation.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SAKLAR SQLITE OTOMATIS ---
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await SharedPrefHelper.setLoginStatus(false);

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

// ATUR RUTE NAVIGASI
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainLayout()),
    GoRoute(
      path: '/penyerap',
      builder: (context, state) => const MainPenyerap(),
    ),
    GoRoute(
      path: '/penyedia',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
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
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7FAF5),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light, 
              seedColor: const Color(0xFF006B23),
              primary: const Color(0xFF006B23),
              onPrimary: Colors.white,
              primaryContainer: const Color(0xFF1C8634),
              onPrimaryContainer: const Color(0xFFF7FFF1),
              surface: const Color(0xFFF7FAF5),
              onSurface: const Color(0xFF191C1A),
              onSurfaceVariant: const Color(0xFF3F4A3D),
            ),
            fontFamily: 'Inter',
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212), 
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark, 
              seedColor: const Color(0xFF006B23),
              primary: const Color(0xFFA8E05F), 
              onPrimary: const Color(0xFF003910),
              primaryContainer: const Color(0xFF005219),
              onPrimaryContainer: const Color(0xFFC4F2A6),
              surface: const Color(0xFF1A1C19), 
              onSurface: const Color(0xFFE2E2E2), 
              onSurfaceVariant: const Color(0xFFBFC9BE), 
            ),
            fontFamily: 'Inter',
            cardTheme: const CardThemeData(
              color: Color(0xFF1E201E), 
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            ),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
