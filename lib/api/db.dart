import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:memo/src/location.dart';
import 'package:memo/src/note.dart';

class Db {
  static late Database db;
  static Future<void> init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'memo.db'),
      version: 2,
      onCreate: (db, version) async => _builder(db),
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1 && newVersion == 2) {
          final batch = db.batch();
          batch.execute(
              'CREATE TABLE locations (id INTEGER PRIMARY KEY, lat REAL NOT NULL, lon REAL NOT NULL, address TEXT)');
          batch.execute('ALTER TABLE notes ADD location_id INT');
          for (final note in dummyNotesWithLocations) {
            batch.execute(
                'INSERT INTO notes (id, text, date_time, timed, location_id) VALUES ("${dummy_notes.length + dummyNotesWithLocations.indexOf(note) + 1}", "${note.text}", "${note.dateTime?.toIso8601String() ?? "null"}", ${note.timed ? 1 : 0}, ${dummyNotesWithLocations.indexOf(note)})');
            batch.execute(
                'INSERT INTO locations (id, lat, lon, address) VALUES (${dummyNotesWithLocations.indexOf(note)}, ${note.location!.lat}, ${note.location!.lon}, ${note.location!.address != null ? '"${note.location!.address}"' : 'null'})');
          }
          batch.commit();
        }
      },
      onOpen: _builder,
    );
  }

  static void _builder(Database db) async {
    final batch = db.batch();
    batch.execute('DROP TABLE IF EXISTS notes');
    batch.execute('DROP TABLE IF EXISTS reminders');
    batch.execute('DROP TABLE IF EXISTS locations');
    batch.execute(
        'CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL, date_time TEXT, timed INTEGER NOT NULL, location_id INTEGER)');
    batch.execute(
        'CREATE TABLE IF NOT EXISTS reminders (id INTEGER PRIMARY KEY, date_time TEXT NOT NULL, note_id INTEGER NOT NULL, UNIQUE(date_time, note_id))');
    batch.execute(
        'CREATE TABLE locations (id INTEGER PRIMARY KEY, lat REAL NOT NULL, lon REAL NOT NULL, address TEXT)');
    for (final note in dummy_notes) {
      final noteId = dummy_notes.indexOf(note) + 1;
      batch.execute(
          'INSERT INTO notes (id, text, date_time, timed) VALUES ("$noteId", "${note.text}", "${note.dateTime?.toIso8601String() ?? "null"}", ${note.timed ? 1 : 0})');
      for (final reminder in note.reminders) {
        batch.execute(
            'INSERT OR IGNORE INTO reminders (date_time, note_id) VALUES ("${reminder.toIso8601String()}", $noteId)');
      }
    }
    for (final note in dummyNotesWithLocations) {
      final noteId =
          dummy_notes.length + dummyNotesWithLocations.indexOf(note) + 1;
      batch.execute(
          'INSERT INTO notes (id, text, date_time, timed, location_id) VALUES ("$noteId", "${note.text}", "${note.dateTime?.toIso8601String() ?? "null"}", ${note.timed ? 1 : 0}, ${dummyNotesWithLocations.indexOf(note)})');
      for (final reminder in note.reminders) {
        batch.execute(
            'INSERT OR IGNORE INTO reminders (date_time, note_id) VALUES ("${reminder.toIso8601String()}", $noteId)');
      }
      batch.execute(
          'INSERT INTO locations (id, lat, lon, address) VALUES (${dummyNotesWithLocations.indexOf(note)}, ${note.location!.lat}, ${note.location!.lon}, ${note.location!.address != null ? '"${note.location!.address}"' : 'null'})');
    }
    batch.commit();
  }

  // get all
  static Future<List<Note>> getAll() async {
    final result = await db.query(
      'notes',
      columns: ['id', 'text', 'date_time', 'timed', 'location_id'],
    );
    return Future.wait(result
        .map((data) async => Note(
              data['text'] as String,
              id: data['id'] as int,
              dateTime: DateTime.tryParse(data['date_time'] as String),
              timed: (data['timed'] as int) == 1,
              location: data['location_id'] == null
                  ? null
                  : await readLocationForNote(id: data['location_id'] as int),
              reminders: await readRemindersForNote(id: data['id'] as int),
            ))
        .toList());
  }

  static Future<int?> _getLocationIdFromNote(int id) async {
    final result = await db.query(
      'notes',
      columns: ['location_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.firstOrNull?['location_id'] as int?;
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

  static Future<Location?> readLocationForNote({required int id}) async {
    final resultList = await db.query(
      'locations',
      columns: ['lat', 'lon', 'address'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return resultList.isEmpty ? null : Location.fromMap(resultList.first);
  }

  // add
  static Future<Note> add(
    String text,
    DateTime? dateTime,
    bool timed, {
    Location? location,
    List<DateTime> reminders = const [],
  }) async {
    int? locationId;
    if (location != null) {
      locationId = await db.insert('locations', location.toMap());
    }

    final id = await db.insert(
      'notes',
      {
        'text': text,
        'date_time': dateTime?.toIso8601String(),
        'timed': timed ? 1 : 0,
        'location_id': locationId,
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
    return Note(
      text,
      id: id,
      dateTime: dateTime,
      timed: timed,
      location: location,
    );
  }

  // update
  static Future<void> update(
    int id,
    String text,
    DateTime? dateTime,
    bool timed,
    int? locationId,
  ) async {
    id = await db.update(
      'notes',
      {
        'text': text,
        'date_time': dateTime?.toIso8601String(),
        'timed': timed ? 1 : 0,
        'location_id': locationId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateLocationForNote(
    int id,
    Location location,
  ) async {
    final locationId = await _getLocationIdFromNote(id);
    if (locationId == null) {
      return await db.insert('locations', location.toMap());
    } else {
      return await db.update(
        'locations',
        location.toMap(),
        where: 'id = ?',
        whereArgs: [locationId],
      );
    }
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

  static Future<void> deleteLocationForNote(int id) async {
    final locationId = await _getLocationIdFromNote(id);
    await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [locationId],
    );
  }
}
