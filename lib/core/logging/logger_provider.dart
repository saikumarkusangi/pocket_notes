import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/logging/console_logger.dart';
import 'package:pocket_notes/core/logging/logger.dart';

/// Global [Logger] instance for the app.
///
/// ```dart
/// final logger = ref.read(loggerProvider);
/// logger.info('Note saved');
/// ```
final loggerProvider = Provider<Logger>(
  (ref) => ConsoleLogger(
    tag: AppConstants.appName,
    logLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
  ),
);
