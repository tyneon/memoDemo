import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:memo/api/local_storage.dart';

const _grey16 = Color(0xff161616);
const _grey30 = Color(0xff303030);
const _grey38 = Color(0xff383838);
const _grey68 = Color(0xff686868);
const _grey92 = Color(0xff929292);

final colorScheme1 = ColorScheme.fromSwatch(
  brightness: Brightness.dark,
  primarySwatch: Colors.lime,
  accentColor: Colors.blue,
  cardColor: _grey38,
  errorColor: Colors.pink,
  backgroundColor: _grey16,
);

final appBarTheme1 = AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  foregroundColor: colorScheme1.primary,
  titleTextStyle: TextStyle(
    fontSize: 30,
    color: colorScheme1.primary,
  ),
);

final colorScheme2 = ColorScheme.fromSwatch(
  brightness: Brightness.light,
  primarySwatch: Colors.lime,
  accentColor: Colors.blue,
  // cardColor: Colors.white,
  errorColor: Colors.pink,
  backgroundColor: Colors.white,
);

final appBarTheme2 = AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  foregroundColor: colorScheme2.onPrimary,
  elevation: 10,
  titleTextStyle: TextStyle(
    fontSize: 30,
    color: colorScheme2.onPrimary,
  ),
);

class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() =>
      _themeBuilder(dark: Storage.instance.getBool('dark') ?? true);

  ThemeData _themeBuilder({required bool dark}) => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.exo2().fontFamily,
        brightness: dark ? Brightness.dark : Brightness.light,
        colorScheme: dark ? colorScheme1 : colorScheme2,
        appBarTheme: dark ? appBarTheme1 : appBarTheme2,
        cardTheme: CardTheme(elevation: dark ? 0 : 7),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
        dividerTheme: const DividerThemeData(
          color: _grey68,
          thickness: 2,
        ),
        // iconTheme: const IconThemeData(color: Colors.pinkAccent),
      );

  void toggle({required bool dark}) {
    Storage.instance.setBool('dark', dark);
    state = _themeBuilder(dark: dark);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeData>(ThemeNotifier.new);
