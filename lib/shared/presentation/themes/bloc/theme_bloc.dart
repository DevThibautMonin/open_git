import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:open_git/shared/core/constants/shared_preferences_keys.dart';
import 'package:open_git/shared/data/datasources/abstractions/shared_preferences_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';
part 'theme_bloc.mapper.dart';

@LazySingleton()
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferencesService sharedPreferencesService;

  ThemeBloc({
    required this.sharedPreferencesService,
  }) : super(ThemeState()) {
    on<UpdateTheme>((event, emit) async {
      final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      await sharedPreferencesService.setString(SharedPreferencesKeys.themeMode, newMode.name);

      emit(state.copyWith(themeMode: newMode));
    });

    on<LoadTheme>((event, emit) {
      final theme = sharedPreferencesService.getString(SharedPreferencesKeys.themeMode);

      switch (theme) {
        case 'dark':
          emit(state.copyWith(themeMode: ThemeMode.dark));
        case 'light':
        default:
          emit(state.copyWith(themeMode: ThemeMode.light));
      }
    });
  }
}
