import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:memo/src/note.dart';

class Db {
  static late Database db;
  static Future<void> init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'memo.db'),
      version: 1,
      onCreate: (db, version) async => _builder(db),
      // onOpen: _builder,
    );
  }

  static void _builder(Database db) async {
    final batch = db.batch();
    batch.execute('DROP TABLE IF EXISTS notes');
    batch.execute(
        'CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL, date_time TEXT, timed INTEGER NOT NULL)');
    batch.execute(
        'CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY, date_time TEXT NOT NULL, note_id INTEGER NOT NULL, UNIQUE(date_time, note_id))');
    for (final note in dummy_notes) {
      batch.execute(
          'INSERT INTO notes (id, text, date_time, timed) VALUES ("${dummy_notes.indexOf(note) + 1}", "${note.text}", "${note.dateTime?.toIso8601String() ?? "null"}", ${note.timed ? 1 : 0})');
      for (final reminder in note.reminders) {
        batch.execute(
            'INSERT OR IGNORE INTO reminders (date_time, note_id) VALUES ("${reminder.toIso8601String()}", ${dummy_notes.indexOf(note) + 1})');
      }
    }
    batch.commit();
  }

  // get all
  static Future<List<Note>> getAll() async {
    final result = await db.query(
      'notes',
      columns: ['id', 'text', 'date_time', 'timed'],
    );
    return Future.wait(result
        .map((data) async => Note(
              data['text'] as String,
              id: data['id'] as int,
              dateTime: DateTime.tryParse(data['date_time'] as String),
              timed: (data['timed'] as int) == 1,
              reminders: await readRemindersForNote(id: data['id'] as int),
            ))
        .toList());
  }

  static Future<List<DateTime>> readRemindersForNote({required int id}) async {
    final resultList = await db.query(
      'reminders',
      columns: ['date_time'],
      where: 'note_id = ?',
      whereArgs: [id],
    );
    return resultList
        .map((result) => DateTime.parse(result['date_time'] as String))
        .toList();
  }

  // add
  static Future<Note> add(
    String text,
    DateTime? dateTime,
    bool timed, [
    List<DateTime> reminders = const [],
  ]) async {
    final id = await db.insert(
      'notes',
      {
        'text': text,
        'date_time': dateTime?.toIso8601String(),
        'timed': timed ? 1 : 0,
      },
    );

    if (reminders.isNotEmpty) {
      for (final reminder in reminders) {
        await db.insert(
          'reminders',
          {
            'date_time': reminder.toIso8601String(),
            'noteId': id,
          },
        );
      }
    }
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

  static Future<void> delete({required int id}) async {
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'reminders',
      where: 'note_id = ?',
      whereArgs: [id],
    );
  }
}
