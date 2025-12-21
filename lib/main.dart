import 'package:flutter/material.dart';
import 'package:open_git/features/home/presentation/ui/home_screen.dart';
import 'package:open_git/shared/core/di/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpenGit',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.orange),
      ),
      home: const HomeScreen(),
    );
  }
}
