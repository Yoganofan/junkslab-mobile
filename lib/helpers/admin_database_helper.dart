import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('junkslab_admin_v9.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWebNoWebWorker;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL, status TEXT NOT NULL, impact_score INTEGER NOT NULL)''',
    );
    await db.execute(
      '''CREATE TABLE articles (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, category TEXT NOT NULL, tag TEXT NOT NULL, content TEXT NOT NULL)''',
    );
    await db.execute(
      '''CREATE TABLE rewards (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, points_required INTEGER NOT NULL, stock INTEGER NOT NULL)''',
    );

    await db.execute('''
      CREATE TABLE transactions_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        user_name TEXT NOT NULL, 
        type TEXT NOT NULL, 
        description TEXT NOT NULL, 
        points INTEGER NOT NULL, 
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE queue_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_name TEXT NOT NULL,
        farm_type TEXT NOT NULL,
        quota_kg INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // --- DATA DUMMY TRANSAKSI (PERPUTARAN POIN) YANG KEMARIN HILANG ---
    await db.insert('transactions_history', {
      'user_name': 'Dapur MBG SDN 1 Bojongsoang',
      'type': 'Earn',
      'description': 'Transaksi Limbah ',
      'points': 1500,
      'date': '2024-06-10',
    });
    await db.insert('transactions_history', {
      'user_name': 'Pasar Sayur Baleendah',
      'type': 'Earn',
      'description': 'Transaksi Limbah ',
      'points': 3000,
      'date': '2024-06-12',
    });
    await db.insert('transactions_history', {
      'user_name': 'Dapur MBG SDN 1 Bojongsoang',
      'type': 'Redeem',
      'description': 'Tukar Poin dengan Barang',
      'points': 1000,
      'date': '2024-06-13',
    });

    // --- DATA DUMMY ANTREAN DENGAN KONSEP BARU ---
    await db.insert('queue_schedule', {
      'farmer_name': 'Dapur MBG SDN 1 Bojongsoang',
      'farm_type': 'Limbah Dapur MBG',
      'quota_kg': 150,
      'status': 'Selesai',
    });
    await db.insert('queue_schedule', {
      'farmer_name': 'Pasar Tradisional Baleendah',
      'farm_type': 'Limbah Sayuran',
      'quota_kg': 300,
      'status': 'Aktif',
    });
    await db.insert('queue_schedule', {
      'farmer_name': 'Petani Sayur Lembang',
      'farm_type': 'Hasil Panen Grade B',
      'quota_kg': 100,
      'status': 'Menunggu',
    });
    await db.insert('queue_schedule', {
      'farmer_name': 'Dapur MBG SMPN 2 Dayeuhkolot',
      'farm_type': 'Limbah Dapur MBG',
      'quota_kg': 250,
      'status': 'Menunggu',
    });
  }

  // --- CRUD BAWAAN (TIDAK ADA YANG DIUBAH, SEMUA PAKAI TRANSACTION) ---
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('users', user);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> readAllUsers() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    await db.transaction((txn) async {
      result = await txn.query('users', orderBy: 'id DESC');
    });
    return result;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        'users',
        user,
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    });
    return count;
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.delete('users', where: 'id = ?', whereArgs: [id]);
    });
    return count;
  }

  Future<int> insertArticle(Map<String, dynamic> article) async {
    final db = await instance.database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('articles', article);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> readAllArticles() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    await db.transaction((txn) async {
      result = await txn.query('articles', orderBy: 'id DESC');
    });
    return result;
  }

  Future<int> updateArticle(Map<String, dynamic> article) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        'articles',
        article,
        where: 'id = ?',
        whereArgs: [article['id']],
      );
    });
    return count;
  }

  Future<int> deleteArticle(int id) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.delete('articles', where: 'id = ?', whereArgs: [id]);
    });
    return count;
  }

  Future<int> insertReward(Map<String, dynamic> reward) async {
    final db = await instance.database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('rewards', reward);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> readAllRewards() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    await db.transaction((txn) async {
      result = await txn.query('rewards', orderBy: 'id DESC');
    });
    return result;
  }

  Future<int> updateReward(Map<String, dynamic> reward) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        'rewards',
        reward,
        where: 'id = ?',
        whereArgs: [reward['id']],
      );
    });
    return count;
  }

  Future<int> deleteReward(int id) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.delete('rewards', where: 'id = ?', whereArgs: [id]);
    });
    return count;
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await instance.database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('transactions_history', transaction);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> readAllTransactions() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    await db.transaction((txn) async {
      result = await txn.query('transactions_history', orderBy: 'id DESC');
    });
    return result;
  }

  Future<int> insertQueue(Map<String, dynamic> queue) async {
    final db = await instance.database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('queue_schedule', queue);
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> readAllQueues() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    await db.transaction((txn) async {
      result = await txn.query('queue_schedule', orderBy: 'id ASC');
    });
    return result;
  }

  Future<int> updateQueue(Map<String, dynamic> queue) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        'queue_schedule',
        queue,
        where: 'id = ?',
        whereArgs: [queue['id']],
      );
    });
    return count;
  }

  Future<int> deleteQueue(int id) async {
    final db = await instance.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.delete(
        'queue_schedule',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    return count;
  }
}
