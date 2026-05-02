import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/services/permission_service.dart';

// Stubs openSettings() to avoid hitting the platform channel.
class _StubPermissionService extends PermissionService {
  bool openSettingsCalled = false;

  @override
  Future<bool> openSettings() async {
    openSettingsCalled = true;
    return true;
  }
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  // ── showRationaleDialog ────────────────────────────────────────────────────

  group('showRationaleDialog', () {
    testWidgets('shows feature name in content text', (tester) async {
      final service = _StubPermissionService();

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => service.showRationaleDialog(ctx, 'camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('camera access'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
    });

    testWidgets('Continue button returns true', (tester) async {
      final service = _StubPermissionService();
      late Future<bool> result;

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => result = service.showRationaleDialog(ctx, 'camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
    });

    testWidgets('Not Now button returns false', (tester) async {
      final service = _StubPermissionService();
      late Future<bool> result;

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => result = service.showRationaleDialog(ctx, 'camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(await result, isFalse);
    });
  });

  // ── showPermanentlyDeniedDialog ────────────────────────────────────────────

  group('showPermanentlyDeniedDialog', () {
    testWidgets('shows permanently-denied message and action buttons', (tester) async {
      final service = _StubPermissionService();

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => service.showPermanentlyDeniedDialog(ctx, 'Camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permanently denied'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Cancel dismisses the dialog without calling openSettings()', (tester) async {
      final service = _StubPermissionService();

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => service.showPermanentlyDeniedDialog(ctx, 'Camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
      expect(service.openSettingsCalled, isFalse);
    });

    testWidgets('Open Settings dismisses dialog and calls openSettings()', (tester) async {
      final service = _StubPermissionService();

      await tester.pumpWidget(_wrap(Builder(builder: (ctx) {
        return ElevatedButton(
          onPressed: () => service.showPermanentlyDeniedDialog(ctx, 'Camera'),
          child: const Text('open'),
        );
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Open Settings'), findsNothing);
      expect(service.openSettingsCalled, isTrue);
    });
  });
}
