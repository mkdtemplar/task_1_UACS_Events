import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS eventstable(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        eventduration INTEGER
      )
      """);
  }

  static Future<sql.Database> db() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}eventsuacs.db';
    print(path);
    return sql.openDatabase(
      'eventsuacs.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createEvent(
      String title, String? descrption, int eventduration) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'eventduration': eventduration
    };
    final id = await db.insert('eventstable', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await SQLHelper.db();
    return db.query('eventstable', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getSingleEvent(int id) async {
    final db = await SQLHelper.db();
    return db.query('eventstable', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String title, String? descrption, int eventduration) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'eventduration': eventduration
    };

    final result =
    await db.update('eventstable', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteEvent(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("eventstable", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
