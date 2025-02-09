import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'carscanner.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS scans (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        manufacturer TEXT,
        specs TEXT,           /* JSON string containing engine, power, torque, etc. */
        productionYears TEXT,
        rarity TEXT,
        description TEXT,
        alsoKnownAs TEXT,    /* JSON string array */
        year TEXT,
        matchAccuracy TEXT,
        timestamp INTEGER NOT NULL,
        images TEXT,         /* JSON string array */
        isSaved INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS collections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS collection_cars (
        collection_id TEXT,
        car_id TEXT,
        timestamp INTEGER,
        PRIMARY KEY (collection_id, car_id),
        FOREIGN KEY (collection_id) REFERENCES collections(id),
        FOREIGN KEY (car_id) REFERENCES scans(id)
      );
    ''');

    // Insert default Favorites collection if it doesn't exist
    final favoritesCollection =
        await db.query('collections', where: 'id = ?', whereArgs: ['1']);
    if (favoritesCollection.isEmpty) {
      await db.insert('collections', {
        'id': '1',
        'name': 'Favorites',
        'icon': '✨',
      });
    }
  }
}
