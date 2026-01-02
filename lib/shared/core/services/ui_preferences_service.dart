import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';

@LazySingleton()
class UiPreferencesService {
  final SharedPreferencesService prefs;

  UiPreferencesService(this.prefs);

  double? getSidebarWidth() {
    return prefs.getDouble(SharedPreferencesKeys.repositorySidebarWidth);
  }

  Future<void> setSidebarWidth(double value) async {
    await prefs.setDouble(SharedPreferencesKeys.repositorySidebarWidth, value);
  }
}
