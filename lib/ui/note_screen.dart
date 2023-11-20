import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo/ui/editing_screen.dart';
import 'package:memo/ui/note_info.dart';
import 'package:memo/src/notes_provider.dart';
import 'package:memo/ui/note_info.dart';

class NoteScreen extends ConsumerWidget {
  final int noteId;
  const NoteScreen(this.noteId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(notesProvider);
    if (asyncNotes.isLoading || asyncNotes.hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final note =
        asyncNotes.value!.singleWhere((element) => element.id == noteId);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(note.dateTime == null
                ? Icons.text_snippet
                : note.timed
                    ? Icons.alarm
                    : Icons.event),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditingScreen(note: note),
            ),
          );
        },
        elevation: 10,
        child: const Icon(Icons.edit),
      ),
      body: NoteInfo(note),
    );
  }
}
