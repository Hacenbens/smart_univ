import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/connectivity_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  final ConnectivityService _service;
  late final StreamSubscription<bool> _subscription;

  ConnectivityCubit(this._service) : super(true) {
    _subscription = _service.onConnectivityChanged.listen(emit);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
