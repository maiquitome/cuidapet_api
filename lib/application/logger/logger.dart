import './i_logger.dart';
import 'package:logger/logger.dart' as log;

class Logger implements ILogger {
  late final dynamic _logger;

  Logger() {
    bool release = true;
    assert(() {
      release = false;
      return true;
    }());
    _logger = log.Logger(
      filter: release ? log.ProductionFilter() : log.DevelopmentFilter(),
    );
  }

  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d(message, error, stackTrace);

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error, stackTrace);

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i(message, error, stackTrace);

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.w(message, error, stackTrace);
}