import 'dart:async';

extension DebounceStream<T> on Stream<T> {
  /// Emits an item only after [duration] has elapsed without another emission.
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    return transform(StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) {
        timer?.cancel();
        timer = Timer(duration, () => sink.add(data));
      },
      handleError: (error, stack, sink) => sink.addError(error, stack),
      handleDone: (sink) {
        timer?.cancel();
        sink.close();
      },
    ));
  }
}
