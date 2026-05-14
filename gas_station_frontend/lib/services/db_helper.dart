import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Cek apakah database sudah dibuat atau belum
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'spbu_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Membuat tabel favorit
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            nama TEXT,
            fasilitas TEXT
          )
        ''');
      },
    );
  }

  // Fungsi menambah favorit
  Future<void> addFavorite(int id, String nama, String fasilitas) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'id': id, 'nama': nama, 'fasilitas': fasilitas},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi mengambil semua favorit
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  // Fungsi menghapus favorit
  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}