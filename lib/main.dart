import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'services/cycle_service.dart';
import 'services/history_service.dart';
import 'services/local_database_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabaseService.init();
  runApp(const WePackagesApp());
}

class WePackagesApp extends StatefulWidget {
  const WePackagesApp({super.key});

  @override
  State<WePackagesApp> createState() => _WePackagesAppState();
}

class _WePackagesAppState extends State<WePackagesApp> {
  late final LocalDatabaseService _db;
  late final CycleService _cycle;
  late final HistoryService _history;
  late final SettingsService _settings;
  late final LanguageProvider _languageProvider;
  AppProvider? _appProvider;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseService();
    _cycle = CycleService(_db);
    _history = HistoryService(_db);
    _settings = SettingsService();
    _languageProvider = LanguageProvider(_settings);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _db.open();
    await _db.ensureFirstLaunchSeed();
    await _languageProvider.load();
    _appProvider = AppProvider(
      db: _db,
      cycleService: _cycle,
      historyService: _history,
    );
    await _appProvider!.bootstrap();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageProvider>.value(
      value: _languageProvider,
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          final colorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), // purple
            brightness: Brightness.light,
          );

          final theme = ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: const Color(0xFFF7F7FB),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Color(0x336750A4),
            ),
          );

          Widget home;
          if (!_ready || _appProvider == null) {
            home = const SplashScreen();
          } else {
            home = ChangeNotifierProvider<AppProvider>.value(
              value: _appProvider!,
              child: const HomeShell(),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WE Packages Manager',
            theme: theme,
            locale: lang.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: home,
          );
        },
      ),
    );
  }
}
