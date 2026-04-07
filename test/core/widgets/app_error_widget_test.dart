import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/widgets/app_error_widget.dart';

void main() {
  Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

  group('AppErrorWidget', () {
    testWidgets('renders default title', (tester) async {
      await tester.pumpWidget(wrap(const AppErrorWidget()));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders custom title', (tester) async {
      await tester.pumpWidget(wrap(
        const AppErrorWidget(title: 'Network error'),
      ));
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('does not show message when omitted', (tester) async {
      await tester.pumpWidget(wrap(const AppErrorWidget()));
      // Only the title text should be present
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('shows detail message when provided', (tester) async {
      await tester.pumpWidget(wrap(
        const AppErrorWidget(message: 'Check your connection'),
      ));
      expect(find.text('Check your connection'), findsOneWidget);
    });

    testWidgets('does not render retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(wrap(const AppErrorWidget()));
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('renders retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(wrap(
        AppErrorWidget(onRetry: () {}),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('retry button uses custom label', (tester) async {
      await tester.pumpWidget(wrap(
        AppErrorWidget(retryLabel: 'Reload', onRetry: () {}),
      ));
      expect(find.text('Reload'), findsOneWidget);
    });

    testWidgets('retry callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        AppErrorWidget(onRetry: () => tapped = true),
      ));
      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isTrue);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(wrap(const AppErrorWidget()));
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });
  });
}
