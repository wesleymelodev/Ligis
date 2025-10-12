// lib/presentation/widgets/custom_input_field.dart
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  /// O controlador para gerenciar o texto do campo.
  final TextEditingController controller;

  /// O texto de dica a ser exibido quando o campo está vazio.
  final String hintText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    // --- AQUI ESTÁ A CORREÇÃO ---
    // 1. Determina se o tema atual é escuro.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Define a cor do texto com base no tema.
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Este TextField vai buscar seu estilo (cores, bordas, etc.)
    // diretamente do `inputDecorationTheme` que definimos no AppTheme.
    // O código aqui fica limpo, focado apenas nas propriedades
    // que mudam a cada uso (controller e hintText).
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      // 3. Aplica a cor do texto dinâmica.
      style: TextStyle(color: textColor),
    );
  }
}
