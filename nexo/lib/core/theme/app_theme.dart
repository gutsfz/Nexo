import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// cores do app
const primaryColor = Color(0xFF00C896);
const darkBackground = Color(0xFF0D0D0D);
const darkSurface = Color(0xFF1A1A1A);
const darkCard = Color(0xFF242424);

ThemeData createDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: darkSurface,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    // fonte inter via google fonts
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: const CardThemeData(color: darkCard, elevation: 0),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: primaryColor.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white, fontSize: 12),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: Colors.white),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
    ),
    // checkbox dos hábitos
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: const BorderSide(color: primaryColor, width: 2),
    ),
  );
}

// tema claro  salvo via sharedpreferences
ThemeData createLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      surface: Colors.white,
      onPrimary: Colors.black,
      onSurface: Colors.black,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    cardTheme: const CardThemeData(color: darkCard, elevation: 0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primaryColor.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.black, fontSize: 12),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: Colors.black),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: const BorderSide(color: primaryColor, width: 2),
    ),
  );
}