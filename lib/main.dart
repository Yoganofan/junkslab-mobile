import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'admin_provider.dart';
import 'prefs_helper.dart';
import 'pages/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await PrefsHelper.setLoggedIn(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminProvider()..refreshDashboard(),
        ),
      ],
      child: const JunksLabAdminApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const MainLayout())],
);

class JunksLabAdminApp extends StatelessWidget {
  const JunksLabAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan Consumer agar bisa mendengar perubahan isDarkMode
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          title: 'JunksLab Admin',
          debugShowCheckedModeBanner: false,

          // Mengatur mode tema berdasarkan Shared Preferences
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // TEMA TERANG
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            cardColor: Colors.white,
          ),

          // TEMA GELAP
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(
              0xFF121212,
            ), // Background gelap
            cardColor: const Color(0xFF1E1E1E), // Warna kotak gelap
            dividerColor: Colors.grey[800],
          ),

          routerConfig: _router,
        );
      },
    );
  }
}
