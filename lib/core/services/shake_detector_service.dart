import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  static const double _threshold = 25.0; // m/s²
  static const _cooldown = Duration(milliseconds: 300);

  final _controller = StreamController<void>.broadcast();
  late final StreamSubscription<AccelerometerEvent> _subscription;
  DateTime? _lastShake;

  ShakeDetectorService() {
    _subscription = accelerometerEventStream().listen(_onEvent);
  }

  Stream<void> get onShake => _controller.stream;

  void _onEvent(AccelerometerEvent e) {
    final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (mag < _threshold) return;
    final now = DateTime.now();
    if (_lastShake != null && now.difference(_lastShake!) < _cooldown) return;
    _lastShake = now;
    _controller.add(null);
  }

  @visibleForTesting
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
