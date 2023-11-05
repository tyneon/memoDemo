import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _grey16 = Color(0xff161616);
const _grey30 = Color(0xff303030);
const _grey38 = Color(0xff383838);
const _grey68 = Color(0xff686868);
const _grey92 = Color(0xff929292);

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.exo2().fontFamily,
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    primarySwatch: Colors.lime,
    accentColor: Colors.blue,
    cardColor: _grey38,
    errorColor: Colors.pink,
    backgroundColor: _grey16,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.lime,
    titleTextStyle: TextStyle(
      fontSize: 30,
      color: Colors.lime,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.bold),
  ),
  dividerTheme: const DividerThemeData(
    color: _grey68,
    thickness: 2,
  ),
  // iconTheme: const IconThemeData(color: Colors.pinkAccent),
);
