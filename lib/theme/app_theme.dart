import 'package:flutter/material.dart';

class AppTheme {
  // カラーパレット
  static const Color bg = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surface2 = Color(0xFF242424);
  static const Color surface3 = Color(0xFF2E2E2E);
  static const Color border = Color(0x14FFFFFF);
  static const Color border2 = Color(0x26FFFFFF);
  static const Color accent = Color(0xFFC8FF00);
  static const Color accentDim = Color(0x1FC8FF00);
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF555555);
  static const Color danger = Color(0xFFFF4D4D);
  static const Color dangerDim = Color(0x1AFF4D4D);

  // 部位カラー
  static const Color colorChest = Color(0xFFC8FF00);
  static const Color colorBack = Color(0xFF5DCAA5);
  static const Color colorLegs = Color(0xFFEF9F27);
  static const Color colorArms = Color(0xFFED93B1);
  static const Color colorShoulders = Color(0xFF7F77DD);
  static const Color colorCore = Color(0xFF888780);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: surface,
          onPrimary: Colors.black,
          onSurface: textPrimary,
        ),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: textTertiary, fontSize: 12),
        ),
        dividerColor: border,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      );
}
