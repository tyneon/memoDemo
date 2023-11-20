import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/src/note.dart';
import 'package:memo/api/db.dart';

class Notes extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async => await Db.getAll();

  Future<void> add(String text, DateTime? dateTime, bool timed) async {
    final note = await Db.add(text, dateTime, timed);
    state = AsyncData([...state.value!, note]);
  }

  Future<void> replace(
    int id,
    String text,
    DateTime? dateTime,
    bool timed,
  ) async {
    final note = await Db.update(id, text, dateTime, timed);
    state = AsyncData(
      [
        ...state.value!.where((element) => element.id != note.id),
        note,
      ],
    );
  }

  void remove(Note note) {
    Db.delete(id: note.id);
    state = AsyncData(
        state.value!.where((element) => element.id != note.id).toList());
  }
}

final notesProvider = AsyncNotifierProvider<Notes, List<Note>>(Notes.new);
