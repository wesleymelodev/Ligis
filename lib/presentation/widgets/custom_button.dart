import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  /// O texto a ser exibido no botão.
  final String text;

  /// A função a ser chamada quando o botão for pressionado.
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Este ElevatedButton buscará seu estilo diretamente do
    // `elevatedButtonTheme` definido no nosso AppTheme.
    // Não precisamos definir cor, padding, shape, etc., aqui.
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
