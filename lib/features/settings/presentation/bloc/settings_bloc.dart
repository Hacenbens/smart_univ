import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // TODO(week-2): load user preferences and emit SettingsLoaded
  }
}
