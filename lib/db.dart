import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:memo/note.dart';

class Db {
  static late Database db;
  static Future<void> init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'memo.db'),
      version: 1,
      onCreate: (db, version) async {
        final batch = db.batch();
        batch.execute(
            'CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL, date_time TEXT, timed INTEGER NOT NULL)');
        batch.execute(
            'CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY, date_time TEXT NOT NULL, note_id INTEGER NOT NULL)');
        batch.commit();
      },
      // onOpen: (db) {
      //   final batch = db.batch();
      //   batch.execute(
      //       'CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL, date_time TEXT, timed INTEGER NOT NULL)');
      //   batch.execute(
      //       'CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY, date_time TEXT NOT NULL, note_id INTEGER NOT NULL)');
      //   batch.commit();
      // },
    );
  }

  // get all
  static Future<List<Note>> getAll() async {
    final result = await db.query(
      'notes',
      columns: ['id', 'text', 'date_time', 'timed'],
    );
    return result
        .map(
          (data) => Note(data['text'] as String,
              id: data['id'] as int,
              dateTime: DateTime.tryParse(data['date_time'] as String),
              timed: (data['timed'] as int) == 1),
        )
        .toList();
  }

  // add
  static Future<Note> add(
    String text,
    DateTime? dateTime,
    bool timed,
  ) async {
    final id = await db.insert(
      'notes',
      {
        'text': text,
        'date_time': dateTime?.toIso8601String(),
        'timed': timed ? 1 : 0,
      },
    );
    return Note(text, id: id, dateTime: dateTime, timed: timed);
  }

  // update
  static Future<Note> update(
    int id,
    String text,
    DateTime? dateTime,
    bool timed,
  ) async {
    id = await db.update(
      'notes',
      {
        'text': text,
        'date_time': dateTime?.toIso8601String(),
        'timed': timed ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return Note(text, id: id, dateTime: dateTime, timed: timed);
  }
}
