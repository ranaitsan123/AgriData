
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_page.dart';
import 'screens/graphs_screen.dart';
import 'screens/history_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  await apiService.loadToken(); // Charger le token depuis SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(apiService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  const MyApp(this.apiService, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AgriData Monitor',
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,

      // 👇 Route initiale dynamique selon présence du token
      initialRoute: apiService.token == null ? '/login' : '/dashboard',

      routes: {
        '/login': (context) => const PremiumLoginPage(),
        '/register': (context) => const PremiumRegisterPage(),
        '/dashboard': (context) => const PremiumDashboardScreen(),
        '/forgot-password': (context) => const PremiumForgotPasswordPage(),
        '/graphs': (context) => GraphPage(),
        '/history': (context) => HistoryPage(),
        '/alertes': (context) => AlertPage(api: apiService),
        '/settings': (context) => const SettingsPage(),
      },

      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const PremiumLoginPage()),
    );
  }
}
