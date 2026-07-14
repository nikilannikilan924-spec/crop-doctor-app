import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('language') ?? 'en';
  await TTSService().init(tamil: langCode == 'ta');
  runApp(CropDoctorApp(initialLocale: Locale(langCode)));
}

class CropDoctorApp extends StatefulWidget {
  final Locale initialLocale;
  const CropDoctorApp({super.key, required this.initialLocale});

  @override
  State<CropDoctorApp> createState() => _CropDoctorAppState();
}

class _CropDoctorAppState extends State<CropDoctorApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(_locale, setLocale),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Crop Doctor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: provider.locale,
            supportedLocales: const [Locale('en'), Locale('ta')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  final Function(Locale) _setLocale;

  LocaleProvider(this._locale, this._setLocale);

  Locale get locale => _locale;

  void switchToTamil() {
    _locale = const Locale('ta');
    _setLocale(_locale);
    notifyListeners();
  }

  void switchToEnglish() {
    _locale = const Locale('en');
    _setLocale(_locale);
    notifyListeners();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          indicatorColor: const Color(0xFF2E7D32).withOpacity(0.12),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: isDark ? Colors.grey[400] : null),
              selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF2E7D32)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: isDark ? Colors.grey[400] : null),
              selectedIcon: const Icon(Icons.history_rounded, color: Color(0xFF2E7D32)),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: isDark ? Colors.grey[400] : null),
              selectedIcon: const Icon(Icons.settings_rounded, color: Color(0xFF2E7D32)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
