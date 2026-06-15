import 'package:flutter/foundation.dart';
import 'package:pocket_notes/core/logging/logger.dart';

class ConsoleLogger implements Logger {
  final String _tag;
  final bool _isEnabled;
  final LogLevel _logLevel;
  final bool _isPrettyPrint;
  final bool _isShowStackTrace;
  final bool _isShowError;
  final bool _isShowContext;
  final bool _isShowTimestamp;

  ConsoleLogger({
    String tag = "ConsoleLogger",
    bool isEnabled = true,
    LogLevel logLevel = LogLevel.debug,
    bool isPrettyPrint = true,
    bool isShowStackTrace = true,
    bool isShowError = true,
    bool isShowContext = true,
    bool isShowTimestamp = true,
  }) : _tag = tag,
       _isEnabled = isEnabled,
       _isPrettyPrint = isPrettyPrint,
       _isShowStackTrace = isShowStackTrace,
       _isShowError = isShowError,
       _isShowContext = isShowContext,
       _isShowTimestamp = isShowTimestamp,
       _logLevel = logLevel;

  @override
  void critical(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void debug(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void error(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void info(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logMessage = StringBuffer();

    if (_tag.isNotEmpty) {
      logMessage.write("[$_tag] ");
    }

    if (_isShowTimestamp) {
      logMessage.write("[${DateTime.now().toIso8601String()}] ");
    }

    if (_isShowContext && context != null) {
      logMessage.write("[Context: $context] ");
    }

    if (_isShowError && error != null) {
      logMessage.write("[Error: $error] ");
    }

    if (_isShowStackTrace && stackTrace != null) {
      logMessage.write("[StackTrace: $stackTrace] ");
    }

    if (_logLevel.index >= level.index) {
      logMessage.write("[${_getColoredLogLevel(level)}] ");
    }

    if (_isPrettyPrint) {
      logMessage.write("[${level.name.toUpperCase()}] ");
    }

    if (_isEnabled) {
      debugPrint(logMessage.toString());
    }
  }

  @override
  void warning(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(message, context: context, error: error, stackTrace: stackTrace);
  }

  // Convert a log level to a colored string representation
  String _getColoredLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[34mDEBUG\x1B[0m'; // Blue
      case LogLevel.info:
        return '\x1B[32mINFO\x1B[0m'; // Green
      case LogLevel.warning:
        return '\x1B[33mWARNING\x1B[0m'; // Yellow
      case LogLevel.error:
        return '\x1B[31mERROR\x1B[0m'; // Red
      case LogLevel.critical:
        return '\x1B[35mCRITICAL\x1B[0m'; // Magenta
    }
  }
}
