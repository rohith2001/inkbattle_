import 'dart:async';
import 'dart:ui';

class Debouncer {
  Duration delay;
  Timer? _timer;
  late VoidCallback _callback;

  Debouncer({this.delay = const Duration(seconds: 1)});

  void debounce(VoidCallback callback) {
    _callback = callback;

    cancel();
    _timer = Timer(delay, flush);
  }

  void cancel() {
    _timer?.cancel();
  }

  void flush() {
    _callback();
    cancel();
  }
}
