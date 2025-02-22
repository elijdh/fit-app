import 'package:flutter/material.dart';

class ThemeClass {
  Color lightPrimaryColor = const  Color(0xFF1A8FE0);
  Color darkPrimaryColor = const Color(0xFF1A8FE0);

  static ThemeMode getSystemThemeMode() {
    final Brightness platformBrightness = WidgetsBinding.instance.window.platformBrightness;
    return platformBrightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
  }

  static ThemeData get systemTheme =>
      getSystemThemeMode() == ThemeMode.light ? lightTheme : darkTheme;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light()
        .copyWith(
      brightness: Brightness.light,
      primary: const Color(0xFF121212),
      onPrimary: const Color(0xFF4C0000),
      primaryContainer: const Color(0xFF7D1E1E),
      onPrimaryContainer: const Color(0xFFE0B4B4),
      secondary: const Color(0xFFB23939),
      onSecondary: const Color(0xFF2E1F1F),
      secondaryContainer: const Color(0xFFE0E0E0),
      onSecondaryContainer: const Color(0xFF333333),
      tertiary: const Color(0xFFC64040),
      onTertiary: const Color(0xFF572E2E),
      tertiaryContainer: const Color(0xFFCCCCCC),
      onTertiaryContainer: const Color(0xFFF0D4D4),
      error: const Color(0xFFDAA6A6),
      onError: const Color(0xFF6D3B3B),
      errorContainer: const Color(0xFFA37878),
      onErrorContainer: const Color(0xFFF2D5D5),
      background: const Color(0xFF1A8FE0),
      onBackground: const Color(0xFFE6E1E5),
      surface: const Color(0xFF1C1B1F),
      onSurface: const Color(0xFFFFFFFF),
      surfaceVariant: const Color(0xFF49454F),
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFE6E1E5),
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: const Color(0xFF724545),
      surfaceTint: const Color(0xFFA42A2A),
    ),
    // - - - - -Light Theme Elevated Button Styles - - - - -
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(
          const Size(double.infinity, 55),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => _themeClass.lightPrimaryColor),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (_) {
            return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10),) );
          },
        ),
        textStyle: MaterialStateProperty.resolveWith(
              (states) =>
          const TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
        ),
        foregroundColor:
        MaterialStateProperty.all<Color>(Colors.purple), //actual text color
      ),
    ),
    // - - - - - - - - - - - - - - -  - - - - -
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark()
        .copyWith(
      brightness: Brightness.dark,
      primary: const Color(0xFF121212),
      onPrimary: const Color(0xFF4C0000),
      primaryContainer: const Color(0xFF7D1E1E),
      onPrimaryContainer: const Color(0xFFE0B4B4),
      secondary: const Color(0xFFB23939),
      onSecondary: const Color(0xFF2E1F1F),
      secondaryContainer: const Color(0xFF121212),
      onSecondaryContainer: const Color(0xFFD8B2B2),
      tertiary: const Color(0xFFC64040),
      onTertiary: const Color(0xFF572E2E),
      tertiaryContainer: const Color(0xFF343434),
      onTertiaryContainer: const Color(0xFFF0D4D4),
      error: const Color(0xFFDAA6A6),
      onError: const Color(0xFF6D3B3B),
      errorContainer: const Color(0xFFA37878),
      onErrorContainer: const Color(0xFFF2D5D5),
      background: const Color(0xFFA42A2A),
      onBackground: const Color(0xFFE6E1E5),
      surface: const Color(0xFF1C1B1F),
      onSurface: const Color(0xFFFFFFFF),
      surfaceVariant: const Color(0xFF49454F),
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFE6E1E5),
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: const Color(0xFF724545),
      surfaceTint: const Color(0xFFA42A2A),
    ),

    // - - - - -Dark Theme Elevated Button Styles - - - - -
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(
          const Size(double.infinity, 55),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => _themeClass.lightPrimaryColor),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (_) {
            return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10),));
          },
        ),
        textStyle: MaterialStateProperty.resolveWith(
              (states) =>
          const TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
        ),
        foregroundColor:
        MaterialStateProperty.all<Color>(Colors.white), //actual text color
      ),
    ),
    // - - - - - - - - - - - - - - -  - - - - -
  );
}

ThemeClass _themeClass = ThemeClass();