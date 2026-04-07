import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/core/widgets/empty_state_widget.dart';

void main() {
  Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

  group('EmptyStateWidget', () {
    testWidgets('renders required title', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(title: 'No items'),
      ));
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('does not show subtitle when omitted', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(title: 'No items'),
      ));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(
          title: 'No items',
          subtitle: 'Come back later',
        ),
      ));
      expect(find.text('Come back later'), findsOneWidget);
    });

    testWidgets('does not render action button when onAction is null',
        (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(title: 'No items', actionLabel: 'Refresh'),
      ));
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders action button when both onAction and label provided',
        (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'No items',
          actionLabel: 'Refresh',
          onAction: () {},
        ),
      ));
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('action callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'No items',
          actionLabel: 'Refresh',
          onAction: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Refresh'));
      expect(tapped, isTrue);
    });

    testWidgets('uses default inbox icon', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(title: 'No items'),
      ));
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(
          title: 'No events',
          icon: Icons.event_busy_outlined,
        ),
      ));
      expect(find.byIcon(Icons.event_busy_outlined), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(title: 'No items'),
      ));
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });
  });
}
