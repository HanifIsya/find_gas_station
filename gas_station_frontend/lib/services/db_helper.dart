import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/spbu.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'spbu_local.db');
    return await openDatabase(
      path,
      version: 2, // Versi dinaikkan menjadi 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            nama TEXT,
            latitude REAL,
            longitude REAL,
            jenis_bbm TEXT,
            fasilitas TEXT,
            jam_operasional TEXT
          )
        ''');
        // Membuat tabel history jika install baru
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keyword TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Menambahkan tabel history jika update dari versi 1
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE search_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              keyword TEXT
            )
          ''');
        }
      },
    );
  }

  // --- FUNGSI FAVORIT ---
  Future<void> addFavorite(Spbu spbu) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': spbu.id,
        'nama': spbu.nama,
        'latitude': spbu.latitude,
        'longitude': spbu.longitude,
        'jenis_bbm': spbu.jenisBbm,
        'fasilitas': spbu.fasilitas,
        'jam_operasional': spbu.jamOperasional,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  // --- FUNGSI RIWAYAT PENCARIAN ---
  Future<void> addSearchHistory(String keyword) async {
    final db = await database;
    // Cek agar tidak menyimpan keyword kosong
    if (keyword.trim().isNotEmpty) {
      await db.insert('search_history', {'keyword': keyword.trim()});
    }
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final db = await database;
    // Mengambil history dari yang terbaru
    return await db.query('search_history', orderBy: 'id DESC');
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }
}