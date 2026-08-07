abstract interface class AppLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message);
  void warning(String message, [Object? error]);
  void error(String message, Object error, StackTrace stackTrace);
}

final class ConsoleLogger implements AppLogger {
  const ConsoleLogger();

  void _write(String level, String message) {
    assert(() {
      // ignore: avoid_print
      print('[VIBE][$level] $message');
      return true;
    }());
  }

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) => _write('DEBUG', '$message${error == null ? '' : ' | $error'}');

  @override
  void info(String message) => _write('INFO', message);

  @override
  void warning(String message, [Object? error]) => _write('WARN', '$message${error == null ? '' : ' | $error'}');

  @override
  void error(String message, Object error, StackTrace stackTrace) => _write('ERROR', '$message | $error\n$stackTrace');
}
