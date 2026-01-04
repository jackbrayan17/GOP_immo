import 'package:logger/logger.dart';

class LoggerService {
  LoggerService._();

  static final LoggerService instance = LoggerService._();

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 6,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );

  void info(String message) => logger.i(message);

  void warn(String message) => logger.w(message);

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}
