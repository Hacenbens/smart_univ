import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Design tokens — forest green primary system
  static const Color _seed = Color(0xFF3F8240);

  static const Color _bgLight = Color(0xFFFAFAF8);
  static const Color _bgDark = Color(0xFF0E110E);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF181B17);

  static const double _radiusCard = 16;
  static const double _radiusButton = 12;
  static const double _radiusInput = 12;

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(
      surface: isLight ? _surfaceLight : _surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isLight ? _bgLight : _bgDark,
      textTheme: _textTheme(cs),
      cardTheme: _cardTheme(cs),
      appBarTheme: _appBarTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
      navigationBarTheme: _navigationBarTheme(cs),
      chipTheme: _chipTheme(cs),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      // 32 / 700 / -0.6 — page-level display
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 38 / 32,
        color: cs.onSurface,
      ),
      // 26 / 700 / -0.4 — section headings
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 32 / 26,
        color: cs.onSurface,
      ),
      // 20 / 650 / -0.2 — card titles
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 26 / 20,
        color: cs.onSurface,
      ),
      // 17 / 600 / -0.1 — list items, app bar
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 22 / 17,
        color: cs.onSurface,
      ),
      // 15 / 400 — body
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 22 / 15,
        color: cs.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 22 / 15,
        color: cs.onSurfaceVariant,
      ),
      // 13 / 500 — labels
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 18 / 13,
        color: cs.onSurfaceVariant,
      ),
      // 12 / 500 / 0.1 — captions, tags
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 16 / 12,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme cs) {
    return CardThemeData(
      elevation: 0,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusCard),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme cs) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: cs.shadow.withValues(alpha: 0.06),
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: cs.onSurface,
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 22),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) {
    final radius = BorderRadius.circular(_radiusInput);
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: cs.error, width: 1.5)),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
      hintStyle: TextStyle(fontSize: 15, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(ColorScheme cs) {
    return NavigationBarThemeData(
      backgroundColor: cs.surface,
      indicatorColor: cs.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: cs.onPrimaryContainer, size: 22);
        }
        return IconThemeData(color: cs.onSurfaceVariant, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? cs.primary : cs.onSurfaceVariant,
        );
      }),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
    );
  }

  static ChipThemeData _chipTheme(ColorScheme cs) {
    return ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
