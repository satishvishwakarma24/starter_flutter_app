// logger_utils.dart
import 'dart:developer' as developer;

abstract class Logger {
  static void info(String message) {
    developer.log(
      message,
      name: 'INFO',
    );
  }

  static void warning(String message) {
    developer.log(
      message,
      name: 'WARNING',
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message) {
    developer.log(
      message,
      name: 'DEBUG',
    );
  }
}

/*
Logger.info("App started");
Logger.debug("Button clicked");
Logger.warning("Low memory");
Logger.error("API failed", exception, stackTrace);
 */
