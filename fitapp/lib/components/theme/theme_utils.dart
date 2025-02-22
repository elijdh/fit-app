import 'package:flutter/material.dart';

ThemeMode getThemeByIndex(int index) {
  switch (index) {
    case 1:
      return ThemeMode.light;
    case 2:
      return ThemeMode.dark;
    case 3:
    default:
      return ThemeMode.system;
  }
}