import 'package:sqflite/sqflite.dart';

class LocalStorage {
  static late Database db;

  static Future<void> initDB() async {
    await openDatabase('main.db', version: 1,
        onCreate: (database, version) async {
      await database.execute("""CREATE TABLE Tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      delivery TEXT NOT NULL,
      isCompleted INTEGER DEFAULT(0),
      color INTEGER DEFAULT(0),
      repeat TEXT
      )""");
    }).then((value) => db = value);
  }

  static Future<List<Map<String, dynamic>>> getItems(String table,
          {String? orderBy}) async =>
      await db.query(table, orderBy: orderBy ?? 'id ASC');
}
