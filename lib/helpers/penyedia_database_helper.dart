import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Pendeteksi kIsWeb
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Import SQLite Web
import 'package:junkslab/models/waste_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWebNoWebWorker;
        return await factory.openDatabase(
          'junkslab_sidang_final.db',
          options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
        );
      } else {
        final dbPath = await getDatabasesPath();
        final String path = join(dbPath, 'junkslab_sidang_final.db');
        
        return await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE waste_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL, 
        category TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        is_listed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pickup_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        waste_item_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identity TEXT NOT NULL UNIQUE, 
        password TEXT NOT NULL,
        role TEXT NOT NULL,           
        created_at TEXT NOT NULL
      )
    ''');
  }


  Future<List<Map<String, dynamic>>> getWasteHistoryWithStatus(String email) async {
    final db = await database;
    
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        w.id,
        w.user_email,
        w.category,
        w.weight_kg,
        w.description,
        w.image_path,
        w.created_at,
        w.is_listed,
        COALESCE(p.status, 'Menunggu') AS status 
      FROM waste_items w
      LEFT JOIN (
        SELECT waste_item_id, status 
        FROM pickup_status 
        GROUP BY waste_item_id 
        HAVING id = MAX(id)
      ) p ON w.id = p.waste_item_id
      WHERE w.user_email = ? 
      ORDER BY w.created_at DESC
    ''', [email]);
    
    return results;
  }

  Future<int> registerUser(String identity, String password, String role) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'identity': identity.trim(),
        'password': password, 
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error register: $e');
      return -1; 
    }
  }

  Future<Map<String, dynamic>?> checkUserLogin(String identity, String password, String role) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'identity = ? AND password = ? AND role = ?',
      whereArgs: [identity.trim(), password, role],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }  

  Future<int> insertWasteItem(WasteItem item) async {
    final db = await database;
    return await db.insert('waste_items', item.toMap());
  }

  Future<List<WasteItem>> getAllWasteItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('waste_items');
    return List.generate(maps.length, (i) => WasteItem.fromMap(maps[i]));
  }

  Future<List<WasteItem>> getListedWasteItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = 
        await db.query('waste_items', where: 'is_listed = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) => WasteItem.fromMap(maps[i]));
  }

  Future<WasteItem?> getWasteItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = 
        await db.query('waste_items', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return WasteItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWasteItem(WasteItem item) async {
    final db = await database;
    return await db.update('waste_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteWasteItem(int id) async {
    final db = await database;
    return await db.delete('waste_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}