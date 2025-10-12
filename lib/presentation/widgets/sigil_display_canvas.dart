import 'package:flutter/material.dart';
import '../../core/logic/sigil_generator.dart';
import 'dart:ui' as ui;

/// Um widget que exibe o sigilo gerado.
/// Ele recebe os dados do sigilo (`SigilData`) e usa um CustomPainter para desenhá-lo.
class SigilDisplayCanvas extends StatelessWidget {
  /// Os dados que contêm os pontos e a cor do sigilo a ser desenhado.
  /// Pode ser nulo se nenhum sigilo foi gerado ainda.
  final SigilData? sigilData;

  /// A cor de fundo do canvas. Padrão é preto.
  final Color backgroundColor;
  final Color? overrideColor;

  const SigilDisplayCanvas({
    super.key,
    this.sigilData,
    this.backgroundColor = Colors.black,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    // CustomPaint é o widget do Flutter para desenhos personalizados.
    // Ele delega o desenho para o 'painter' e o 'foregroundPainter'.
    // Usamos um ClipRRect para garantir que o desenho não saia dos limites do widget.
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: CustomPaint(
        // O 'painter' desenha *atrás* do widget filho ('child').
        // Usamos ele para pintar o fundo.
        painter: BackgroundPainter(backgroundColor),
        // O 'foregroundPainter' desenha *na frente* do widget filho.
        // É aqui que desenhamos nosso sigilo.
        foregroundPainter: SigilPainter(sigilData, overrideColor: overrideColor),
        // O 'child' é o conteúdo do widget. Um SizedBox.expand garante que
        // o CustomPaint ocupe todo o espaço disponível.
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Painter responsável por desenhar o sigilo na tela.
class SigilPainter extends CustomPainter {
  final SigilData? sigilData;
  final Color? overrideColor;
  SigilPainter(this.sigilData, {this.overrideColor});

  @override
  void paint(Canvas canvas, Size size) {
    drawSigil(canvas, size, sigilData, overrideColor);
  }
  static void drawSigil(ui.Canvas canvas, ui.Size size, SigilData? sigilData, Color? overrideColor) {
    // Se não houver dados do sigilo, não há nada a fazer.
    if (sigilData == null || sigilData!.points.isEmpty) {
      return;
    }

    // Configura o 'pincel' (Paint) para desenhar as linhas.
    final paint = Paint()
      ..color = overrideColor ?? sigilData!.color // Usa a cor calculada pela nossa lógica
      ..style = PaintingStyle.stroke // Define que queremos desenhar linhas, não preencher formas
      ..strokeWidth = 3.0 // A espessura da linha
      ..strokeCap = StrokeCap.round // Deixa as pontas das linhas arredondadas
      ..strokeJoin = StrokeJoin.round; // Deixa as junções das linhas arredondadas

    // Cria um objeto Path, que é uma sequência de linhas e curvas.
    final path = Path();

    // Move o 'pincel' para o ponto inicial do sigilo, sem desenhar.
    path.moveTo(sigilData!.points.first.dx, sigilData!.points.first.dy);

    // Conecta todos os outros pontos com linhas.
    for (int i = 1; i < sigilData!.points.length; i++) {
      final point = sigilData!.points[i];
      path.lineTo(point.dx, point.dy);
    }

    // Finalmente, desenha o caminho completo no canvas de uma só vez.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SigilPainter oldDelegate) {
    // O Flutter chama este método para decidir se o widget precisa ser redesenhado.
    // Nós dizemos para ele redesenhar apenas se o `sigilData` mudou.
    // Isso otimiza a performance, evitando redesenhos desnecessários.
    return oldDelegate.sigilData != sigilData || oldDelegate.overrideColor != overrideColor;
  }
}

/// Painter simples para desenhar uma cor de fundo sólida.
class BackgroundPainter extends CustomPainter {
  final Color color;

  BackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  static void drawBackground(ui.Canvas canvas, ui.Size size, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    // Redesenha o fundo apenas se a cor mudar.
    return oldDelegate.color != color;
  }
}
