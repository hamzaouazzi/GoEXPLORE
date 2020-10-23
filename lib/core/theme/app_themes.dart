import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  light,
  dark,
}

final appThemes = {
  AppTheme.dark: ThemeData(
    primaryColor: Colors.indigo[900],
    accentColor: Colors.indigo[900],
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
    brightness: Brightness.dark,
  ),
  AppTheme.light: ThemeData(
    primaryColor: Colors.indigo[900],
    splashColor: Color(0xDDFDEDF3),
    accentColor: Colors.indigo[900],
    brightness: Brightness.light,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
  ),
};
