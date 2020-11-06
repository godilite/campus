import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDb {
  SqliteDb._();
  static final SqliteDb db = SqliteDb._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "campuselDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE user ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "username TEXT,"
          "email TEXT,"
          "email_verified_at TEXT,"
          "bio TEXT,"
          "phone TEXT,"
          "profileUrl TEXT,"
          "coverPhoto TEXT,"
          "uid TEXT,"
          "user_type TEXT,"
          "address TEXT,"
          "created_at TEXT,"
          "updated_at TEXT,"
          "long TEXT,"
          "lat TEXT"
          ")");

      await db.execute("CREATE TABLE wishlist ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "location TEXT,"
          "profileUrl TEXT,"
          "image TEXT,"
          "amount INTEGER,"
          "longitude TEXT,"
          "latitude TEXT,"
          "is_forsale INTEGER,"
          "content TEXT,"
          "hashtags TEXT,"
          "user_id INTEGER,"
          "created_at TEXT,"
          "updated_at TEXT,"
          "long TEXT,"
          "lat TEXT"
          ")");
    });
  }
}
