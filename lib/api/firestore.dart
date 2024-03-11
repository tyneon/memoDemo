import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/src/location.dart';
import 'package:memo/src/note.dart';

class Firestore {
  static Future<List<Note>> getAll() async {
    final notesCollection = await FirebaseFirestore.instance
        .collection('notes')
        .orderBy('date_time')
        .get();
    final notes = <Note>[];
    for (final doc in notesCollection.docs) {
      final reminders = await FirebaseFirestore.instance
          .collection('notes')
          .doc(doc.id)
          .collection('reminders')
          .get();
      final data = doc.data();
      notes.add(
        Note(
          data['text'],
          id: doc.id,
          dateTime: data['date_time'] == null
              ? null
              : DateTime.tryParse(data['date_time'] as String),
          timed: data['timed'],
          location: data['location'] == null
              ? null
              : Location(
                  lat: data['location']['lat'] + 0.0,
                  lon: data['location']['lon'] + 0.0,
                  address: data['location']['address'],
                ),
          reminders: reminders.docs
              .map((reminderDoc) => DateTime.fromMillisecondsSinceEpoch(
                      reminderDoc['date_time'].seconds * 1000)
                  .toLocal())
              .toList(),
        ),
      );
    }
    return notes;
  }

  static Future<Note> add(
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location,
    List<DateTime> reminders,
  ) async {
    final notesCollection = FirebaseFirestore.instance.collection('notes');
    final result = await notesCollection.add({
      'text': text,
      'date_time': dateTime?.toIso8601String(),
      'timed': timed,
      'location': location == null
          ? null
          : {
              'lat': location.lat,
              'lon': location.lon,
              'address': location.address,
            },
    });
    for (final reminder in reminders) {
      await notesCollection.doc(result.id).collection('reminders').add({
        'dateTime': reminder,
      });
    }
    return Note(
      text,
      id: result.id,
      dateTime: dateTime,
      timed: timed,
      location: location,
      reminders: reminders,
    );
  }

  static Future<void> update(
    String id,
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location,
    List<DateTime> reminders,
  ) async {
    final docToUpdate = FirebaseFirestore.instance.collection('notes').doc(id);
    await docToUpdate.update({
      'text': text,
      'date_time': dateTime?.toIso8601String(),
      'timed': timed,
      'location': location == null
          ? null
          : {
              'lat': location.lat,
              'lon': location.lon,
              'address': location.address,
            },
    });
    for (final reminder in reminders) {
      await docToUpdate.collection('reminders').add({
        'dateTime': reminder,
      });
    }
  }

  static Future<void> delete({required String id}) async {
    final docToDelete = FirebaseFirestore.instance.collection('notes').doc(id);
    // Документы дочерней коллекции нужно удалять по одному
    // до удаления родительского документа
    final reminders = await docToDelete.collection('reminders').get();
    for (final reminder in reminders.docs) {
      await docToDelete.collection('reminders').doc(reminder.id).delete();
    }
    await docToDelete.delete();
  }
}
