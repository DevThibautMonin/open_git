part of 'theme_bloc.dart';

@MappableClass()
class ThemeState with ThemeStateMappable {
  final ThemeMode themeMode;

  const ThemeState({
    this.themeMode = ThemeMode.light,
  });
}
