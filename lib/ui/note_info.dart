import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:memo/src/note.dart';

class NoteInfo extends StatelessWidget {
  final Note note;
  const NoteInfo(this.note, {super.key});

  String reminderMessage(
    DateTime? deadline,
    DateTime dateTime, {
    bool timed = false,
  }) {
    if (deadline == null) {
      return "on ${DateFormat("dd/MM/yy").format(dateTime)} at ${DateFormat("HH:mm").format(dateTime)}";
    }
    final difference = deadline.difference(dateTime);
    if (!timed) {
      if (deadline.day == dateTime.day) {
        return "on the same day at ${DateFormat("HH:mm").format(dateTime)}";
      }
    } else {
      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes before";
      }
      if (difference.inHours < 24) {
        if (difference.inMinutes - difference.inHours * 60 == 0) {
          return "${difference.inHours} hours before";
        }
        return "${difference.inHours} hours ${difference.inMinutes - difference.inHours * 60} minutes before";
      }
    }
    final differenceInDays = difference.inDays +
        (DateTime(0, 0, 0, deadline.hour, deadline.minute)
                .difference(DateTime(0, 0, 0, dateTime.hour, dateTime.minute))
                .isNegative
            ? 1
            : 0);
    return "${differenceInDays == 1 ? "on the day before" : "$differenceInDays days before"} at ${DateFormat("HH:mm").format(dateTime)}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.dateTime != null)
                note.timed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(note.dateTime!),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                          ),
                          Text(
                            DateFormat('dd/MM/yy').format(note.dateTime!),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          DateFormat('d/M/y').format(note.dateTime!),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ),
              const Divider(),
              Container(
                // height: 400,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  note.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (note.location != null) ...[
                const Divider(),
                Text(
                  "Location:",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(note.location.toString()),
              ],
              const Divider(),
              Text(
                "Reminders:",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: note.reminders.length,
                  itemBuilder: (context, index) => Text(
                    reminderMessage(
                      note.dateTime,
                      note.reminders[index],
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
