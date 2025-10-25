import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFF121212);
  static const Color backgroundColor = Color(0xFF000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
    );
  }

  static ThemeData get systemTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ),
    );
  }
}
