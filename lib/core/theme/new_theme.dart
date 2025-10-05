
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF007BFF);
  static const Color secondary = Color(0xFF6C757D);
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);
  static const Color lightGray = Color(0xFFF1F3F5);
  static const Color mediumGray = Color(0xFFDEE2E6);
  static const Color darkGray = Color(0xFF495057);
  static const Color background = Color(0xFFF8F9FA);
  static const Color text = Color(0xFF333333);
}

final ThemeData newTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: Colors.white,
    background: AppColors.background,
    error: AppColors.danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.text,
    onBackground: AppColors.text,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  ),
  appBarTheme: const AppBarTheme(
    color: AppColors.lightGray,
    elevation: 1,
    iconTheme: IconThemeData(color: AppColors.darkGray),
    titleTextStyle: TextStyle(
      color: AppColors.darkGray,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primary,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.mediumGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    labelStyle: const TextStyle(color: AppColors.secondary),
  ),
);
