// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/about_screen.dart';

class AppRoutes {
  // Modifique o método para aceitar a função de callback
  static Route<dynamic> generateRoute(RouteSettings settings, {required VoidCallback toggleTheme}) {
    switch (settings.name) {
      case '/':
      // Passe a função para a HomeScreen
        return MaterialPageRoute(builder: (_) => HomeScreen(toggleTheme: toggleTheme));

      case AboutScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Nenhuma rota definida para ${settings.name}'),
            ),
          ),
        );
    }
  }
}
