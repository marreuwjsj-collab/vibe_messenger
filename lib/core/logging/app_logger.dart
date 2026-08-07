import 'dart:async';

final class AppLogger {
  static void info(String message) => _write('INFO', message);
  static void warning(String message) => _write('WARN', message);
  static void error(String message, [Object? error, StackTrace? stack]) => _write('ERROR', '$message ${error ?? ''}');
  static void _write(String level, String message) { assert(() { print('[VIBE][$level] $message'); return true; }()); }
}
