import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget wrapper que adiciona gradiente roxo sutil no tema escuro
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return child;

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.9),
          radius: 1.4,
          colors: [Color(0xFF1C0D42), darkBackground],
          stops: [0.0, 0.55],
        ),
      ),
      child: child,
    );
  }
}

const primaryColor = Color(0xFF7C3AED); // roxo principal
const darkBackground = Color(0xFF0A0A14);
const darkSurface = Color(0xFF1A1A1A);
const darkCard = Color(0xFF242424);

ThemeData createDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: darkSurface,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
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
    cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
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