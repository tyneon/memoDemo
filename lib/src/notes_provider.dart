import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/src/current_note_provider.dart';

import 'package:memo/src/location.dart';
import 'package:memo/src/note.dart';
import 'package:memo/api/db.dart';

class Notes extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async => await Db.getAll()
    ..sort();

  Future<void> add(
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location,
  ) async {
    final note = await Db.add(
      text,
      dateTime,
      timed,
      location: location,
    );
    state = AsyncData([...state.value!, note]..sort());
  }

  Future<void> replace(
    int id,
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location,
  ) async {
    final oldNote = state.value!.singleWhere((element) => element.id == id);
    int? locationId;
    if (location != null) {
      locationId = await Db.updateLocationForNote(id, location);
    } else if (oldNote.location != null) {
      await Db.deleteLocationForNote(id);
    }
    await Db.update(id, text, dateTime, timed, locationId);
    final newNote = Note(
      text,
      id: id,
      dateTime: dateTime,
      timed: timed,
      location: location,
    );
    state = AsyncData(
      [
        ...state.value!.where((element) => element.id != id),
        newNote,
      ]..sort(),
    );
    ref.read(currentNoteProvider.notifier).set(newNote);
  }

  void remove(Note note) {
    Db.delete(id: note.id);
    state = AsyncData(
        state.value!.where((element) => element.id != note.id).toList());
  }
}

final notesProvider = AsyncNotifierProvider<Notes, List<Note>>(Notes.new);
