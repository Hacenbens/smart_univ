// Widget-level smoke test.
// Requires go_router and equatable to be installed (`flutter pub get`).
// Run: flutter test test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCampusApp());
    await tester.pumpAndSettle();
    // Starts logged out — login page must be visible.
    expect(find.text('SmartCampus'), findsOneWidget);
    expect(find.text('Sign in (mock)'), findsOneWidget);
  });

  testWidgets('Tapping sign in navigates to home', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCampusApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in (mock)'));
    await tester.pumpAndSettle();
    // AppBar title + NavigationBar tab both show "Home" — check the AppBar specifically
    expect(find.text('Home — coming soon'), findsOneWidget);
  });
}
