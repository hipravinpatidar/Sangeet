import 'dart:convert';
import 'package:sangit/model/sangeet_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shlokas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE favourite(id INTEGER PRIMARY KEY AUTOINCREMENT, music_model TEXT UNIQUE)",
        );
      },
    );
  }

  static Future<void> insertBookmark(Sangeet musicData) async {
    final db = await database;
    await db.insert(
      'favourite',
      {'music_model': json.encode(musicData.toJson())},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> deleteBookmark(Sangeet musicData) async {
    final db = await database;
    await db.delete(
      'favourite',
      where: 'music_model = ?',
      whereArgs: [json.encode(musicData.toJson())],
    );
  }

  static Future<List<Sangeet>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favourite');

    return List.generate(maps.length, (i) {
      return Sangeet.fromJson(json.decode(maps[i]['music_model']));
    });
  }
}
