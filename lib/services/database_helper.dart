import 'package:resto_app/models/favorite_restaurant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const _tableName = 'favorites';

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'restaurant.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT,
            pictureId TEXT,
            city TEXT,
            rating REAL
          )
        ''');
      },
    );
  }

  Future<void> insertFavorite(
    FavoriteRestaurant restaurant) async {
  final db = await database;

  await db.insert(
    _tableName,
    restaurant.toMap(), // <-- penting
    conflictAlgorithm:
        ConflictAlgorithm.replace,
  );
}
  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FavoriteRestaurant>> getFavorites() async {
  final db = await database;
  final result = await db.query(_tableName);

  return result
      .map((e) => FavoriteRestaurant.fromMap(e))
      .toList();
}

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final result =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }
}