import 'package:memo/src/location.dart';

class Note implements Comparable<Note> {
  final String id;
  final String text;
  final DateTime? dateTime;
  final bool timed;
  final Location? location;
  final List<DateTime> reminders;
  Note(
    this.text, {
    this.id = "0",
    this.dateTime,
    this.timed = false,
    this.location,
    this.reminders = const <DateTime>[],
  }) : assert(timed ? dateTime != null : true);

  @override
  int compareTo(Note other) {
    if (dateTime == null) {
      if (other.dateTime == null) {
        id.compareTo(other.id);
      }
      return 1;
    }
    if (other.dateTime == null) {
      return -1;
    }
    return dateTime!.compareTo(other.dateTime!);
  }
}

final dummyNotesWithLocations = <Note>[
  Note(
    "Retrovawe/synth rock концерт",
    dateTime: DateTime(2023, 11, 26, 20),
    timed: true,
    reminders: [
      DateTime(2023, 11, 25, 20),
      DateTime(2023, 11, 26, 18),
    ],
    location: Location(
      lat: 41.7051147,
      lon: 44.7904186,
      address:
          "Philosof CLub, Giorgi Akhvlediani Street 6, 0108 Tbilisi, Georgia",
    ),
  ),
  Note(
    "Тбилисское море",
    location: Location(
      lat: 41.725590,
      lon: 44.878647,
    ),
  ),
];

final dummy_notes = <Note>[
  Note(
    "Подготовить приложение для лекции по Flutter",
    dateTime: DateTime(2023, 11, 6, 20),
    timed: true,
    reminders: [
      DateTime(2023, 11, 6, 19, 45),
      DateTime(2023, 11, 6, 12, 00),
    ],
  ),
  Note(
    "Вечеринка!",
    dateTime: DateTime(2023, 11, 11),
    timed: false,
    reminders: [
      DateTime(2023, 11, 10, 12, 00),
      DateTime(2023, 11, 11, 10, 00),
    ],
  ),
  Note(
    "Купить microSD карту",
  ),
  Note(
    "Цены на билеты???",
  ),
  Note(
    "Поездка",
    dateTime: DateTime(2023, 11, 30),
    timed: false,
    reminders: [
      DateTime(2023, 11, 28, 10, 00),
    ],
  ),
  Note(
    "Новый год!",
    dateTime: DateTime(2024, 01, 01, 00, 00),
    timed: true,
    reminders: [
      DateTime(2023, 12, 25, 12, 00),
      DateTime(2023, 12, 31, 23, 55),
    ],
  ),
  Note(
    "Это просто пример очень длинной заметки, которая должна занять как минимум две строки и всё авно не влезть в карточку в списке заметок",
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 6, 11, 30),
    timed: true,
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 8, 11, 30),
    timed: true,
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 10, 11, 30),
    timed: true,
  ),
  Note(
    "Подготовить занятие по хранению данных",
    dateTime: DateTime(2023, 11, 13, 20),
    timed: true,
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 14, 11, 30),
    timed: true,
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 16, 11, 30),
    timed: true,
  ),
  Note(
    "Тренировка",
    dateTime: DateTime(2023, 11, 18, 11, 30),
    timed: true,
  ),
];
