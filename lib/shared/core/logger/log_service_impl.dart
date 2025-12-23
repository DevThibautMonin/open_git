import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:open_git/shared/core/logger/custom_log_filter.dart';
import 'package:open_git/shared/core/logger/log_service.dart';

@Singleton(as: LogService)
class LogServiceImpl extends LogService {
  late Logger _logger;

  @override
  Future<void> init() async {
    _logger = Logger(
      filter: CustomLogFilter(),
      output: MultiOutput([
        ConsoleOutput(),
      ]),
      printer: PrefixPrinter(
        PrettyPrinter(
          colors: kDebugMode,
          printEmojis: false,
          methodCount: 0,
          noBoxingByDefault: true,
          levelColors: {
            Level.debug: AnsiColor.fg(215),
            Level.info: AnsiColor.fg(045),
            Level.warning: AnsiColor.fg(011),
            Level.error: AnsiColor.fg(001),
          },
          dateTimeFormat: (date) {
            return date.toIso8601String();
          },
        ),
      ),
    );
  }

  @override
  void debug(String message) {
    _logger.d(message);
  }

  @override
  void error(String message) {
    _logger.e(message);
  }

  @override
  void info(String message) {
    _logger.i(message);
  }

  @override
  void warning(String message) {
    _logger.w(message);
  }

  @override
  void logJsonData(String? data) {
    if (data == null) {
      _logger.d("No data");
    } else {
      final jsonObject = json.decode(data);
      const jsonEncoder = JsonEncoder.withIndent('    ');
      final formattedJson = jsonEncoder.convert(jsonObject);
      _logger.d("JSON $formattedJson");
    }
  }
}
