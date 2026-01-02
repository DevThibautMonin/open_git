import 'dart:convert';

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

  @override
  Future<void> setBytes(String key, List<int> value) async {
    final encoded = base64Encode(value);
    await prefs.setString(key, encoded);
  }

  @override
  List<int>? getBytes(String key) {
    final encoded = prefs.getString(key);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  @override
  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }
}
