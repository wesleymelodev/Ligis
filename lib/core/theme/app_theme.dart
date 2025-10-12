// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais da marca (usadas em ambos os temas)
  static const Color primaryColor = Color(0xFF8A2BE2); // Roxo

  // --- CORES DO TEMA ESCURO ---
  static const Color darkBackgroundColor = Color(0xFF121212); // Quase preto
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Cor de superfície escura
  static const Color darkTextColor = Colors.white;
  static const Color darkHintColor = Color(0xFF888888);

  // --- CORES DO TEMA CLARO ---
  static const Color lightBackgroundColor = Color(0xFFF5F5F5); // Um branco acinzentado
  static const Color lightSurfaceColor = Colors.white; // Branco puro para cards/inputs
  static const Color lightTextColor = Colors.black;
  static const Color lightHintColor = Color(0xFF9E9E9E); // Um cinza mais claro

  // Tema claro totalmente implementado
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,

    // Define a paleta de cores geral para o tema claro
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      background: lightBackgroundColor,
      surface: lightSurfaceColor,
    ),

    // Define o estilo padrão para a AppBar no tema claro
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurfaceColor,
      foregroundColor: lightTextColor, // Cor dos ícones e do título
      elevation: 1, // Uma leve sombra para destacar no fundo claro
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Define o estilo padrão para todos os TextFields no tema claro
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor,
      hintStyle: const TextStyle(color: lightHintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Borda sutil
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Borda sutil
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // Define o estilo padrão para todos os ElevatedButtons no tema claro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Texto do botão branco para contraste
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // Tema escuro (movi as cores para cima para melhor organização)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,

    // Define a paleta de cores geral
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
    ),

    // Define o estilo padrão para a AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Define o estilo padrão para todos os TextFields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      hintStyle: const TextStyle(color: darkHintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // Define o estilo padrão para todos os ElevatedButtons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: darkTextColor, // Cor do texto/ícone do botão
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
