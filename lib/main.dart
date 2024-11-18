import 'package:flutter/material.dart';
import 'screens/add_truck_tire_screen.dart' as add_tire;
import 'screens/home_screen.dart' as home;
import 'screens/login_screen.dart';
import 'screens/maintenance_history_screen.dart' as maintenance_history;
import 'screens/maintenance_record_screen.dart';
import 'screens/request_service_order_screen.dart' as request_service;
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(const RecapProApp());
}

class RecapProApp extends StatelessWidget {
  const RecapProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDarkMode, __) {
        return MaterialApp(
          title: 'TireTrack',
          theme: isDarkMode ? _darkTheme() : _lightTheme(),
          home: SignInPage(), // Altere aqui para a tela de login
          routes: {
            '/home': (context) => home.HomeScreen(
                  isAdmin: false,
                ),
            '/dashboard': (context) =>
                AdminDashboardScreen(), // Nova rota para o Dashboard
            '/request-service-order': (context) =>
                request_service.RequestServiceOrderScreen(),
            '/maintenance-record': (context) => MaintenanceRecordScreen(),
            '/maintenance-history': (context) =>
                maintenance_history.MaintenanceHistoryScreen(),
            '/add-truck-tire': (context) => add_tire.AddTruckTireScreen(),
          },
        );
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      primaryColor: Color(0xFF333A82),
      hintColor: Color(0xFF4C509B),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
        displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFF6466B4),
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Color(0xFF333A82),
        secondary: Color(0xFF7D7CCC),
        surface: Colors.white,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF1A1A2E),
      hintColor: Color(0xFF4C509B),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
        displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xFF6466B4),
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.dark().copyWith(
        primary: Color(0xFF333A82),
        secondary: Color(0xFF7D7CCC),
        surface: Colors.grey[850],
      ),
    );
  }
}

ValueNotifier<bool> themeNotifier = ValueNotifier(false);
