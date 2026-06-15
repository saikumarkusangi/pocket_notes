// Severity levels for logging
enum LogLevel { debug, info, warning, error, critical }

abstract class Logger {
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  });
  void debug(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.debug,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
  void info(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.info,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
  void warning(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.warning,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
  void error(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.error,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
  void critical(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.critical,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
}
