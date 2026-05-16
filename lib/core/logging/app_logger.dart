import 'dart:async';

enum LogLevel { debug, info, warning, error }

final class AppLogger {
  AppLogger(this._tag);

  final String _tag;

  static final StreamController<_LogEntry> _controller =
      StreamController<_LogEntry>.broadcast();

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _controller.stream.listen(_onLog);
  }

  static void _onLog(_LogEntry entry) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = switch (entry.level) {
      LogLevel.debug => 'D',
      LogLevel.info => 'I',
      LogLevel.warning => 'W',
      LogLevel.error => 'E',
    };
    final msg = '[$prefix][$timestamp][${entry.tag}] ${entry.message}';
    if (entry.level == LogLevel.error) {
      // ignore: avoid_print
      print(msg);
      if (entry.error != null) {
        // ignore: avoid_print
        print('  Error: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        // ignore: avoid_print
        print('  StackTrace: ${entry.stackTrace}');
      }
    } else {
      // ignore: avoid_print
      print(msg);
    }
  }

  void debug(String message) => _add(LogLevel.debug, message);

  void info(String message) => _add(LogLevel.info, message);

  void warning(String message) => _add(LogLevel.warning, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _controller.add(_LogEntry(
        level: LogLevel.error,
        tag: _tag,
        message: message,
        error: error,
        stackTrace: stackTrace,
      ));

  void _add(LogLevel level, String message) => _controller.add(
        _LogEntry(level: level, tag: _tag, message: message),
      );

  static void dispose() => _controller.close();
}

final class _LogEntry {
  const _LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}
