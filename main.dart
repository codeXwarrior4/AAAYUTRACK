import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Localization + Theme
import 'localization.dart';
import 'theme.dart';

// Services
import 'services/notification_service.dart';

// Screens
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/language_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/onboarding_flow.dart';
import 'screens/reminders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/telemedicine_screen.dart';
import 'screens/ai_checkup_page.dart'; // AI Checkup
import 'widgets/app_drawer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Open required Hive boxes
  await Hive.openBox('aayutrack_box');
  await Hive.openBox('aayutrack_reminders');
  await Hive.openBox('aayutrack_reports'); // For AI reports

  await NotificationService.init();

  runApp(const RootApp());
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});
  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  final box = Hive.box('aayutrack_box');
  bool _darkMode = false;
  Locale? _locale;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _darkMode = box.get('darkMode', defaultValue: false);

    final sp = await SharedPreferences.getInstance();
    final code = sp.getString('locale_code') ?? box.get('locale_code');

    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }

    setState(() => _ready = true);
  }

  Future<void> _changeLocale(Locale? locale) async {
    _locale = locale;
    final sp = await SharedPreferences.getInstance();

    if (locale == null) {
      await sp.remove('locale_code');
      box.delete('locale_code');
    } else {
      await sp.setString('locale_code', locale.languageCode);
      box.put('locale_code', locale.languageCode);
    }
    setState(() {});
  }

  void _toggleTheme(bool dark) {
    _darkMode = dark;
    box.put('darkMode', dark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MyAppTheme(
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: "AayuTrack",
        debugShowCheckedModeBanner: false,
        theme: buildAayuTrackLightTheme(),
        darkTheme: buildAayuTrackDarkTheme(),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
          Locale('kn'),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RootDecider(),
        routes: {
          '/landing': (_) => const LandingScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const RegisterScreen(),
          '/onboarding': (_) => const OnboardingFlow(),
          '/dashboard': (_) => const MainScaffold(),
          '/ai': (_) => const AICheckupPage(),
          '/reminders': (_) => const RemindersScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/reports': (_) => const ReportsScreen(),
          '/emergency': (_) => const EmergencyScreen(),
          '/telemedicine': (_) => const TelemedicineScreen(),
          '/language': (_) => LanguageScreen(onChangedLocale: _changeLocale),
        },
      ),
    );
  }
}

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});
  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  final box = Hive.box('aayutrack_box');
  bool _loading = true;
  bool _loggedIn = false;
  bool _onboarded = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _loggedIn = box.get('loggedIn', defaultValue: false);
      _onboarded = box.get('onboarded', defaultValue: false);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_loggedIn && !_onboarded) return const LandingScreen();
    if (!_loggedIn) return const LoginScreen();
    if (!_onboarded) return const OnboardingFlow();

    return const MainScaffold();
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final List<Widget> pages = [
    const DashboardScreen(),
    const AICheckupPage(),
    const RemindersScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<String> titles = [
    'Dashboard',
    'AI Checkup',
    'Reminders',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined), label: 'AI'),
          NavigationDestination(
              icon: Icon(Icons.alarm_outlined), label: 'Reminders'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class MyAppTheme extends InheritedWidget {
  final Function(bool) toggleTheme;

  const MyAppTheme({
    super.key,
    required this.toggleTheme,
    required super.child,
  });

  static MyAppTheme of(BuildContext context) {
    final MyAppTheme? result =
        context.dependOnInheritedWidgetOfExactType<MyAppTheme>();
    assert(result != null, 'No MyAppTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MyAppTheme oldWidget) => false;
}
