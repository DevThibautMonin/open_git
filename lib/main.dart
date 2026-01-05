import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_git/features/repository/presentation/ui/repository_screen.dart';
import 'package:open_git/shared/core/di/injectable.dart';
import 'package:open_git/shared/presentation/themes/bloc/theme_bloc.dart';
import 'package:open_git/shared/presentation/themes/dark_theme.dart';
import 'package:open_git/shared/presentation/themes/light_theme.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.maximize();
  if (Platform.isMacOS) {
    final int intervalInSeconds = 3600;
    await autoUpdater.setFeedURL('https://raw.githubusercontent.com/DevThibautMonin/open_git/main/appcast.xml');
    await autoUpdater.setScheduledCheckInterval(intervalInSeconds);
  }
  await configureDependencies();
  runApp(
    BlocProvider(
      create: (context) => getIt<ThemeBloc>()..add(LoadTheme()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OpenGit',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.themeMode,
          home: const RepositoryScreen(),
        );
      },
    );
  }
}
