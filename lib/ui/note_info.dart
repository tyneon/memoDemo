import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'package:memo/src/note.dart';

class NoteInfo extends StatelessWidget {
  final Note note;
  const NoteInfo(this.note, {super.key});

  String reminderMessage(
    BuildContext context,
    DateTime? deadline,
    DateTime dateTime, {
    bool timed = false,
  }) {
    final date = DateFormat("dd/MM/yy").format(dateTime);
    final time = DateFormat("HH:mm").format(dateTime);
    if (deadline == null) {
      return AppLocalizations.of(context)!.reminderTextUnspecified(date, time);
    }
    final difference = deadline.difference(dateTime);
    if (!timed) {
      if (deadline.day == dateTime.day) {
        return AppLocalizations.of(context)!.reminderTextSameDay(time);
      }
    } else {
      if (difference.inMinutes < 60) {
        return AppLocalizations.of(context)!
            .reminderTextCountMinutesBefore(difference.inMinutes);
      }
      if (difference.inHours < 24) {
        if (difference.inMinutes - difference.inHours * 60 == 0) {
          return AppLocalizations.of(context)!
              .reminderTextCountHoursBefore(difference.inHours);
        }
        return AppLocalizations.of(context)!
            .reminderTextCountHoursMinutesBefore(difference.inHours,
                difference.inMinutes - difference.inHours * 60);
      }
    }
    final differenceInDays = difference.inDays +
        (DateTime(0, 0, 0, deadline.hour, deadline.minute)
                .difference(DateTime(0, 0, 0, dateTime.hour, dateTime.minute))
                .isNegative
            ? 1
            : 0);
    return differenceInDays == 1
        ? AppLocalizations.of(context)!.reminderTextOnTheDayBefore(time)
        : AppLocalizations.of(context)!
            .reminderTextCountDaysBefore(differenceInDays, time);
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
                  "${AppLocalizations.of(context)!.locationSectionTitle}:",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(note.location.toString()),
              ],
              const Divider(),
              Text(
                "${AppLocalizations.of(context)!.remindersSectionTitle}:",
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
                      context,
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
