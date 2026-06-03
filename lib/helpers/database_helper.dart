import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE limbahs (
  id $idType,
  nama_limbah $textType,
  berat_kg $intType,
  tanggal $textType,
  status $textType
  )
''');
  }

  // 1. CREATE
  Future<int> insertLimbah(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('limbahs', row);
  }

  // 2. READ
  Future<List<Map<String, dynamic>>> getAllLimbah() async {
    final db = await instance.database;
    return await db.query('limbahs', orderBy: 'id DESC');
  }

  // 3. UPDATE
  Future<int> updateLimbah(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('limbahs', row, where: 'id = ?', whereArgs: [id]);
  }

  // 4. DELETE
  Future<int> deleteLimbah(int id) async {
    final db = await instance.database;
    return await db.delete('limbahs', where: 'id = ?', whereArgs: [id]);
  }
}