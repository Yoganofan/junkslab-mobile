import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Wajib untuk deteksi kIsWeb

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('junkslab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = filePath;

    // --- INI KUNCI JAWABAN DARI ANALISAMU ---
    // Kalau BUKAN di Web (berarti di HP/Laptop), baru kita cari folder fisiknya
    if (!kIsWeb) {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }
    // Kalau di Web, dia akan tetap pakai path = 'junkslab.db' aja!
    // ----------------------------------------

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE limbah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_limbah TEXT,
        berat_kg INTEGER,
        tanggal TEXT,
        status TEXT
      )
    ''');
  }

  // --- Fungsi CRUD ---
  Future<int> insertLimbah(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('limbah', data);
  }

  Future<List<Map<String, dynamic>>> getAllLimbah() async {
    final db = await instance.database;
    // Tampilkan dari yang paling baru di-scan (DESC)
    return await db.query('limbah', orderBy: 'id DESC');
  }

  Future<int> deleteLimbah(int id) async {
    final db = await instance.database;
    return await db.delete('limbah', where: 'id = ?', whereArgs: [id]);
  }
}