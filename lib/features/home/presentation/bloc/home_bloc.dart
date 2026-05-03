import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/shake_detector_service.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/usecases/schedule_reminders_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> with WidgetsBindingObserver {
  final ShakeDetectorService _shakeDetector;
  final ScheduleRemindersUseCase _scheduleReminders;
  late final StreamSubscription<void> _shakeSub;
  int _shakeCount = 0;

  HomeBloc(this._shakeDetector, this._scheduleReminders)
      : super(const HomeInitial()) {
    WidgetsBinding.instance.addObserver(this);
    on<_HomeShakeReceived>(_onShakeReceived);
    on<_HomeAppResumed>(_onAppResumed);
    _shakeSub = _shakeDetector.onShake.listen((_) {
      HapticFeedback.mediumImpact();
      add(const _HomeShakeReceived());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) add(const _HomeAppResumed());
  }

  void _onShakeReceived(
    _HomeShakeReceived event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeShakeDetected(++_shakeCount));
  }

  Future<void> _onAppResumed(
    _HomeAppResumed event,
    Emitter<HomeState> emit,
  ) async {
    await _scheduleReminders(const NoParams());
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeSub.cancel();
    return super.close();
  }
}
