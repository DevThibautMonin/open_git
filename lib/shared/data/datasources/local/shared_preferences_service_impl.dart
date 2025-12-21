import 'package:injectable/injectable.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: SharedPreferencesService)
class SharedPreferencesServiceImpl implements SharedPreferencesService {
  final SharedPreferences prefs;

  SharedPreferencesServiceImpl({
    required this.prefs,
  });

  @override
  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  @override
  String? getString(String key) => prefs.getString(key);
}
