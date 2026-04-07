import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    // ── Basics ────────────────────────────────────────────────────────────────

    group('lightTheme', () {
      final theme = AppTheme.lightTheme;

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('brightness is light', () {
        expect(theme.colorScheme.brightness, Brightness.light);
      });

      test('seed produces an indigo-family primary', () {
        // The generated primary should be a blue/indigo hue (200–280 deg).
        final hsl = HSLColor.fromColor(theme.colorScheme.primary);
        expect(hsl.hue, inInclusiveRange(200, 280));
      });
    });

    group('darkTheme', () {
      final theme = AppTheme.darkTheme;

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('brightness is dark', () {
        expect(theme.colorScheme.brightness, Brightness.dark);
      });
    });

    // ── Typography ────────────────────────────────────────────────────────────

    group('typography', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      test('headlineMedium is 20 sp / weight 500', () {
        final style = light.textTheme.headlineMedium!;
        expect(style.fontSize, 20);
        expect(style.fontWeight, FontWeight.w500);
      });

      test('bodyLarge is 16 sp / weight 400', () {
        final style = light.textTheme.bodyLarge!;
        expect(style.fontSize, 16);
        expect(style.fontWeight, FontWeight.w400);
      });

      test('labelSmall is 12 sp / weight 400', () {
        final style = light.textTheme.labelSmall!;
        expect(style.fontSize, 12);
        expect(style.fontWeight, FontWeight.w400);
      });

      test('dark theme preserves typography sizes', () {
        expect(dark.textTheme.headlineMedium!.fontSize, 20);
        expect(dark.textTheme.bodyLarge!.fontSize, 16);
        expect(dark.textTheme.labelSmall!.fontSize, 12);
      });
    });

    // ── CardTheme ─────────────────────────────────────────────────────────────

    group('cardTheme', () {
      final card = AppTheme.lightTheme.cardTheme;

      test('elevation is 0 (shadow via border)', () {
        expect(card.elevation, 0);
      });

      test('shape has 16 radius', () {
        final rrb = card.shape as RoundedRectangleBorder;
        final radius = rrb.borderRadius as BorderRadius;
        expect(radius.topLeft.x, 16);
      });

      test('surfaceTintColor is transparent', () {
        expect(card.surfaceTintColor, Colors.transparent);
      });

      test('margin is zero', () {
        expect(card.margin, EdgeInsets.zero);
      });
    });

    // ── AppBarTheme ───────────────────────────────────────────────────────────

    group('appBarTheme', () {
      final bar = AppTheme.lightTheme.appBarTheme;

      test('elevation is 0', () {
        expect(bar.elevation, 0);
      });

      test('scrolledUnderElevation is 1', () {
        expect(bar.scrolledUnderElevation, 1);
      });

      test('centerTitle is true', () {
        expect(bar.centerTitle, isTrue);
      });

      test('surfaceTintColor is transparent', () {
        expect(bar.surfaceTintColor, Colors.transparent);
      });

      test('title is 17 sp / weight 600', () {
        expect(bar.titleTextStyle!.fontSize, 17);
        expect(bar.titleTextStyle!.fontWeight, FontWeight.w600);
      });
    });

    // ── ElevatedButtonTheme ───────────────────────────────────────────────────

    group('elevatedButtonTheme', () {
      final style = AppTheme.lightTheme.elevatedButtonTheme.style!;

      test('elevation is 0', () {
        final elevation = style.elevation?.resolve({});
        expect(elevation, 0);
      });

      test('shape has 12 radius', () {
        final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
        final radius = shape.borderRadius as BorderRadius;
        expect(radius.topLeft.x, 12);
      });

      test('minimum height is 52', () {
        final size = style.minimumSize?.resolve({});
        expect(size?.height, 52);
      });

      test('text style is 15 sp / weight 600', () {
        final ts = style.textStyle?.resolve({});
        expect(ts?.fontSize, 15);
        expect(ts?.fontWeight, FontWeight.w600);
      });
    });

    // ── InputDecorationTheme ──────────────────────────────────────────────────

    group('inputDecorationTheme', () {
      final input = AppTheme.lightTheme.inputDecorationTheme;

      test('is filled', () {
        expect(input.filled, isTrue);
      });

      test('border has 12 radius', () {
        final border = input.border as OutlineInputBorder;
        expect(border.borderRadius.topLeft.x, 12);
      });

      test('focused border has width 2', () {
        final border = input.focusedBorder as OutlineInputBorder;
        expect(border.borderSide.width, 2);
      });
    });
  });
}
