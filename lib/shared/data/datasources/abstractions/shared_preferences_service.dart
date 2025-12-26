abstract class SharedPreferencesService {
  Future<void> setString(String key, String value);
  String? getString(String key);

  Future<void> setBytes(String key, List<int> value);
  List<int>? getBytes(String key);
}
