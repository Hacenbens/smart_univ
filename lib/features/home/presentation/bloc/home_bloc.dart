import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/shake_detector_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ShakeDetectorService _shakeDetector;
  late final StreamSubscription<void> _shakeSub;
  int _shakeCount = 0;

  HomeBloc(this._shakeDetector) : super(const HomeInitial()) {
    on<_HomeShakeReceived>(_onShakeReceived);
    _shakeSub = _shakeDetector.onShake.listen((_) {
      HapticFeedback.mediumImpact();
      add(const _HomeShakeReceived());
    });
  }

  void _onShakeReceived(
    _HomeShakeReceived event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeShakeDetected(++_shakeCount));
  }

  @override
  Future<void> close() {
    _shakeSub.cancel();
    return super.close();
  }
}
