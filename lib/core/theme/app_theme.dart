import 'package:flutter/material.dart';

/// Global theme for SmartCampus.
///
/// Usage:
///   theme: AppTheme.lightTheme
///   darkTheme: AppTheme.darkTheme
class AppTheme {
  AppTheme._();

  // ── Seed & radius constants ─────────────────────────────────────────────────

  /// Indigo-blue seed that drives all generated surface/container tones.
  static const Color _seed = Color(0xFF3D5AFE);

  static const double _radiusCard = 16;
  static const double _radiusButton = 12;
  static const double _radiusInput = 12;

  // ── Public entry points ─────────────────────────────────────────────────────

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  // ── Builder ─────────────────────────────────────────────────────────────────

  static ThemeData _build(Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _textTheme(cs),
      cardTheme: _cardTheme(cs),
      appBarTheme: _appBarTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
    );
  }

  // ── Typography ──────────────────────────────────────────────────────────────

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: cs.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: cs.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────────────────────────

  static CardThemeData _cardTheme(ColorScheme cs) {
    return CardThemeData(
      elevation: 0,
      color: cs.surface,
      // Disable Material 3 tonal tint so the soft box-shadow reads clearly.
      surfaceTintColor: Colors.transparent,
      shadowColor: cs.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusCard),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  static AppBarTheme _appBarTheme(ColorScheme cs) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: cs.shadow.withValues(alpha: 0.08),
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: cs.onSurface,
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 22),
    );
  }

  // ── ElevatedButton ──────────────────────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── InputDecoration ─────────────────────────────────────────────────────────

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radiusInput),
      borderSide: BorderSide(color: cs.outline),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border.copyWith(
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: cs.error),
      ),
    );
  }
}
