import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/widgets/loading_widget.dart';

void main() {
  Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

  group('LoadingWidget', () {
    testWidgets('renders spinner without message', (tester) async {
      await tester.pumpWidget(wrap(const LoadingWidget()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(wrap(const LoadingWidget(message: 'Loading…')));
      expect(find.text('Loading…'), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(wrap(const LoadingWidget()));
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
