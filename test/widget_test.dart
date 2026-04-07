import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/main.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
    await initDependencies();
  });

  tearDown(() async => GetIt.instance.reset());

  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const SmartCampusApp());
    await tester.pumpAndSettle();
    expect(find.text('SmartCampus'), findsOneWidget);
    expect(find.text('Sign in (mock)'), findsOneWidget);
  });

  testWidgets('Tapping sign in navigates to home', (tester) async {
    await tester.pumpWidget(const SmartCampusApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in (mock)'));
    await tester.pumpAndSettle();
    expect(find.text('Home — coming soon'), findsOneWidget);
  });
}
