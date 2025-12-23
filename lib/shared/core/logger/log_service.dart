abstract class LogService {
  void info(String message);
  void warning(String message);
  void error(String message);
  void debug(String message);
  void logJsonData(String? data);
  Future<void> init();
}
