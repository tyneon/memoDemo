import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/note.dart';

class Notes extends Notifier<List<Note>> {
  @override
  List<Note> build() => dummy_notes;

  void add(Note note) {
    state = [...state, note];
  }

  void remove(Note note) {
    state = state.where((element) => element != note).toList();
  }
}

final notesProvider = NotifierProvider<Notes, List<Note>>(Notes.new);
