import 'dart:convert';

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

  /// Get expansion state for branch groups
  /// Returns `Map<String, bool>` where key is "local:prefix" or "remote:prefix"
  Map<String, bool> getBranchGroupsExpansionState() {
    final json = prefs.getString(SharedPreferencesKeys.branchGroupsExpansionState);
    if (json == null || json.isEmpty) {
      return {}; // Default: all collapsed
    }

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (e) {
      return {};
    }
  }

  /// Save expansion state for branch groups
  Future<void> setBranchGroupsExpansionState(Map<String, bool> state) async {
    final json = jsonEncode(state);
    await prefs.setString(SharedPreferencesKeys.branchGroupsExpansionState, json);
  }
}
