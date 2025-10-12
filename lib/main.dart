// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

// 1. Converta MyApp para um StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 2. Crie uma variável de estado para controlar o modo do tema
  ThemeMode _themeMode = ThemeMode.dark;

  // 3. Crie um método para alternar o tema
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ligis - Sigil Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // 4. Use a variável de estado aqui
      themeMode: _themeMode,

      initialRoute: '/',
      // 5. Passe a função de toggle para as rotas filhas usando um InheritedWidget (ou outra forma de gerenciamento de estado)
      // Uma forma simples para começar é modificar a geração de rotas para passar a função.
      onGenerateRoute: (settings) => AppRoutes.generateRoute(settings, toggleTheme: _toggleTheme),

      debugShowCheckedModeBanner: false,
    );
  }
}

    