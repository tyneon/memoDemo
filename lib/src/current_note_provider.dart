import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/src/note.dart';

class CurrentNoteNotifier extends Notifier<Note?> {
  @override
  Note? build() => null;

  void set(Note note) {
    state = note;
  }

  void clear() {
    state = null;
  }
}

final currentNoteProvider =
    NotifierProvider<CurrentNoteNotifier, Note?>(CurrentNoteNotifier.new);
