import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/preference_helper.dart';
import 'data/repositories/mood_repository.dart';
import 'presentation/providers/mood_provider.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);

  // Inicializar almacenamiento y persistencia
  final prefHelper = await PreferenceHelper.create();
  final dbHelper = DatabaseHelper.instance;
  final moodRepository = MoodRepository(dbHelper, prefHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider(moodRepository)..initialize()),
        ChangeNotifierProvider(create: (_) => SecurityProvider(prefHelper)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefHelper)),
      ],
      child: const MoodWaveApp(),
    ),
  );
}

class MoodWaveApp extends StatelessWidget {
  const MoodWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MoodWave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
