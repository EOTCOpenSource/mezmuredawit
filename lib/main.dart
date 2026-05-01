import 'package:flutter/material.dart';
import 'providers/app_state.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrayerApp());
}

class PrayerApp extends StatelessWidget {
  const PrayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Mezmure Dawit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9E2A2B), // Maroon/Dark Red
              brightness: Brightness.light,
              surface: const Color(0xFFF9F9F9),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9F9F9),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9E2A2B),
              brightness: Brightness.dark,
              surface: const Color(0xFF121212),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          themeMode: currentMode,
          home: const HomePage(),
        );
      },
    );
  }
}
