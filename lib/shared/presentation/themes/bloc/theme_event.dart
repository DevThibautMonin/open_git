part of 'theme_bloc.dart';

sealed class ThemeEvent {}

class UpdateTheme extends ThemeEvent {
  UpdateTheme();
}

class LoadTheme extends ThemeEvent {
  LoadTheme();
}
