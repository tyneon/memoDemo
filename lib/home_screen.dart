import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo/note_screen.dart';

import 'package:memo/notes_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesList = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: const Row(
          children: [
            Icon(
              Icons.edit_notifications,
              size: 36,
            ),
            Text("Remind me! app"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 10,
        child: const Icon(Icons.add),
      ),
      body: notesList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    final note = notesList[index];
                    final icon = note.dateTime == null
                        ? Icons.text_snippet
                        : note.timed
                            ? Icons.alarm
                            : Icons.event;
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteScreen(note),
                            ),
                          );
                        },
                        leading: note.dateTime == null
                            ? null
                            : SizedBox(
                                width: 50,
                                child: note.timed
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              DateFormat.Hm()
                                                  .format(note.dateTime!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                            ),
                                          ),
                                          FittedBox(
                                            child: Text(
                                              DateFormat(note.dateTime!.year ==
                                                          DateTime.now().year
                                                      ? 'dd/MM'
                                                      : 'dd/MM/yy')
                                                  .format(note.dateTime!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                            ),
                                          ),
                                        ],
                                      )
                                    : FittedBox(
                                        child: Text(
                                          DateFormat('dd/MM')
                                              .format(note.dateTime!),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                        ),
                                      ),
                              ),
                        title: Text(
                          note.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          icon,
                          color: note.reminders.isEmpty
                              ? null
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }),
            )
          : Center(
              child: Text(
                "No notes here yet!",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
    );
  }
}
