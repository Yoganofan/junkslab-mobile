import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Pendeteksi kIsWeb
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Import SQLite Web

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
    if (kIsWeb) {
      // INI KUNCINYA: Pakai mode NoWebWorker!
      // 100% SQLite asli, database beneran, TAPI ngelewatin error terminal Mac lu.
      var factory = databaseFactoryFfiWebNoWebWorker;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    } else {
      // Mode HP Asli (Android/iOS)
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  // Syarat Dosen: Sintaks SQLite Murni
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
    // Tampilkan dari data yang paling baru di-scan
    return await db.query('limbah', orderBy: 'id DESC');
  }

  Future<int> deleteLimbah(int id) async {
    final db = await instance.database;
    return await db.delete('limbah', where: 'id = ?', whereArgs: [id]);
  }
}
