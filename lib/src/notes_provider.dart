import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/src/current_note_provider.dart';

import 'package:memo/src/location.dart';
import 'package:memo/src/note.dart';
import 'package:memo/api/firestore.dart';

class Notes extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async => await Firestore.getAll()
    ..sort();

  Future<void> add(
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location, [
    List<DateTime> reminders = const <DateTime>[],
  ]) async {
    final note = await Firestore.add(
      text,
      dateTime,
      timed,
      location,
      reminders,
    );
    state = AsyncData([...state.value!, note]..sort());
  }

  Future<void> replace(
    String id,
    String text,
    DateTime? dateTime,
    bool timed,
    Location? location,
    List<DateTime> reminders,
  ) async {
    await Firestore.update(
      id,
      text,
      dateTime,
      timed,
      location,
      reminders,
    );
    final newNote = Note(
      text,
      id: id.toString(),
      dateTime: dateTime,
      timed: timed,
      location: location,
      reminders: reminders,
    );
    state = AsyncData(
      [
        ...state.value!.where((element) => element.id != id),
        newNote,
      ]..sort(),
    );
    ref.read(currentNoteProvider.notifier).set(newNote);
  }

  void remove(Note note) async {
    await Firestore.delete(id: note.id);
    state = AsyncData(
        state.value!.where((element) => element.id != note.id).toList());
  }
}

final notesProvider = AsyncNotifierProvider<Notes, List<Note>>(Notes.new);
