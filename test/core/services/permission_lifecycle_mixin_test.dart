import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/services/permission_lifecycle_mixin.dart';
import 'package:smart_univ/core/services/permission_service.dart';

// Stubs checkPermission() without hitting the platform channel.
class _StubPermissionService extends PermissionService {
  PermissionResult stubbedResult;
  int checkCallCount = 0;

  _StubPermissionService(this.stubbedResult);

  @override
  Future<PermissionResult> checkPermission(Permission permission) async {
    checkCallCount++;
    return stubbedResult;
  }
}

// Minimal widget that uses the mixin.
class _TestWidget extends StatefulWidget {
  final _StubPermissionService service;
  final List<PermissionResult> results;

  const _TestWidget({required this.service, required this.results});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with WidgetsBindingObserver, PermissionLifecycleMixin<_TestWidget> {
  @override
  Permission get observedPermission => Permission.camera;

  @override
  PermissionService get permissionService => widget.service;

  @override
  void onPermissionStatusChanged(PermissionResult result) {
    widget.results.add(result);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  group('PermissionLifecycleMixin', () {
    testWidgets('calls checkPermission and notifies on AppLifecycleState.resumed',
        (tester) async {
      final results = <PermissionResult>[];
      final service = _StubPermissionService(PermissionResult.granted);

      await tester.pumpWidget(
          MaterialApp(home: _TestWidget(service: service, results: results)));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(service.checkCallCount, 1);
      expect(results, [PermissionResult.granted]);
    });

    testWidgets('does not call checkPermission on paused / inactive / detached',
        (tester) async {
      final results = <PermissionResult>[];
      final service = _StubPermissionService(PermissionResult.granted);

      await tester.pumpWidget(
          MaterialApp(home: _TestWidget(service: service, results: results)));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pumpAndSettle();

      expect(service.checkCallCount, 0);
      expect(results, isEmpty);
    });

    testWidgets('calls checkPermission on each successive resume', (tester) async {
      final results = <PermissionResult>[];
      final service = _StubPermissionService(PermissionResult.permanentlyDenied);

      await tester.pumpWidget(
          MaterialApp(home: _TestWidget(service: service, results: results)));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      service.stubbedResult = PermissionResult.granted;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(service.checkCallCount, 2);
      expect(results, [PermissionResult.permanentlyDenied, PermissionResult.granted]);
    });

    testWidgets('does not call checkPermission after dispose', (tester) async {
      final results = <PermissionResult>[];
      final service = _StubPermissionService(PermissionResult.granted);

      await tester.pumpWidget(
          MaterialApp(home: _TestWidget(service: service, results: results)));

      // Replace with an unrelated widget, triggering dispose on _TestWidget.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(service.checkCallCount, 0);
      expect(results, isEmpty);
    });
  });
}
