abstract class SharedPreferencesService {
  Future<void> setString(String key, String value);
  String? getString(String key);
}
