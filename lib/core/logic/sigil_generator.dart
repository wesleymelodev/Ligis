import 'dart:math';
import 'dart:ui'; // Necessário para a classe Color
import 'package:crypto/crypto.dart'; // Para o hash SHA-256
import 'dart:convert'; // Para utf8.encode

/// Modelo para armazenar os dados processados do sigilo.
/// A UI usará um objeto desta classe para saber o que desenhar.
class SigilData {
  final List<Offset> points;
  final Color color;

  SigilData({required this.points, required this.color});
}

class SigilGenerator {
  // O mesmo conjunto de caracteres usado na lógica original.
  static const String _charSet = "0123456789abcdefghijklmnopqrstuvwxyz";

  // Mapas para ângulo e distância, convertidos para Dart.
  static final Map<String, double> _angleMap = {
    for (var i = 0; i < _charSet.length; i++)
      _charSet[i]: i * (360 / _charSet.length)
  };

  static final Map<String, double> _distanceMap = {
    for (var i = 0; i < _charSet.length; i++) _charSet[i]: (i * 3) + 50
  };

  // Mapa de cores numerológicas, usando a classe Color do Flutter.
  static final Map<int, Color> _colorMap = {
    1: const Color(0xFFFF0000), // Vermelho
    2: const Color(0xFFFFA500), // Laranja
    3: const Color(0xFFFFFF00), // Amarelo
    4: const Color(0xFF008000), // Verde (usei um verde mais padrão)
    5: const Color(0xFF00FFFF), // Azul claro (Ciano)
    6: const Color(0xFF0000FF), // Azul
    7: const Color(0xFF8A2BE2), // Roxo (Azul Violeta)
    8: const Color(0xFFFFC0CB), // Rosa
    9: const Color(0xFF808080), // Cinza
  };

  /// 1. Reduz a frase: remove vogais e caracteres duplicados.
  String _reducePhrase(String text) {
    const String vowels = "aeiouAEIOU";
    String reducedText = text.toLowerCase().split('').where((char) {
      return _charSet.contains(char) && !vowels.contains(char);
    }).join();

    // Remove duplicados mantendo a ordem.
    var seen = <String>{};
    return reducedText
        .split('')
        .where((char) => seen.add(char))
        .toList()
        .join('');
  }

  /// 2. Gera um hash a partir do texto reduzido.
  String _generateHash(String text, {int length = 36}) {
    final reducedText = _reducePhrase(text);
    final bytes = utf8.encode(reducedText); // Converte para bytes
    final digest = sha256.convert(bytes); // Gera o hash SHA-256
    final fullHash = digest.toString();

    // Converte o hash hexadecimal para um hash alfanumérico baseado no _charSet.
    String alphanumericHash = '';
    for (int i = 0; i < length && i < fullHash.length; i++) {
      final char = fullHash[i];
      final intValue = int.parse(char, radix: 16);
      alphanumericHash += _charSet[intValue % _charSet.length];
    }
    return alphanumericHash;
  }

  /// 3. Calcula o dígito numerológico da frase para definir a cor.
  int _calculatePhraseColorDigit(String text) {
    int letterToNumber(String c) {
      if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
        // Converte a letra para um número de 1 a 9.
        return ((c.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0)) % 9) + 1;
      } else if (RegExp(r'[0-9]').hasMatch(c)) {
        return int.parse(c);
      }
      return 0; // Ignora outros caracteres.
    }

    int total = text
        .split('')
        .where((c) => RegExp(r'[a-zA-Z]').hasMatch(c))
        .map(letterToNumber)
        .fold(0, (prev, curr) => prev + curr);

    // Reduz o número a um único dígito (ex: 42 -> 4+2=6).
    while (total > 9) {
      total = total
          .toString()
          .split('')
          .map(int.parse)
          .fold(0, (prev, curr) => prev + curr);
    }
    return total == 0 ? 9 : total; // Evita retornar 0.
  }

  /// Função principal que gera os dados do sigilo.
  /// Recebe a intenção e as dimensões da área de desenho.
  SigilData generate(String phrase, Size canvasSize) {
    final hashString = _generateHash(phrase);
    final colorDigit = _calculatePhraseColorDigit(phrase);
    final color = _colorMap[colorDigit] ?? const Color(0xFFFFFFFF);

    // 1. Gere os pontos em um sistema de coordenadas virtual (começando em 0,0)
    List<Offset> virtualPoints = [Offset.zero];
    double currentAngle = 0;
    for (int i = 0; i < hashString.length; i++) {
      final char = hashString[i];
      final dist = _distanceMap[char] ?? 50.0;
      final angleIncrement = _angleMap[char] ?? 10.0;
      currentAngle += angleIncrement;
      final rad = currentAngle * (pi / 180);
      final prevPoint = virtualPoints.last;
      virtualPoints.add(Offset(prevPoint.dx + dist * cos(rad), prevPoint.dy + dist * sin(rad)));
    }

    // 2. Calcule os limites (bounding box) do desenho virtual
    if (virtualPoints.length < 2) return SigilData(points: [], color: color);

    double minX = virtualPoints.map((p) => p.dx).reduce(min);
    double maxX = virtualPoints.map((p) => p.dx).reduce(max);
    double minY = virtualPoints.map((p) => p.dy).reduce(min);
    double maxY = virtualPoints.map((p) => p.dy).reduce(max);

    final sigilWidth = maxX - minX;
    final sigilHeight = maxY - minY;

    // 3. Calcule a escala e os deslocamentos para centralizar e ajustar o sigilo
    const double padding = 40.0; // Adiciona um respiro nas bordas
    final canvasDrawableWidth = canvasSize.width - padding;
    final canvasDrawableHeight = canvasSize.height - padding;

    // Calcula a escala para que o sigilo caiba, mantendo a proporção
    final double scaleX = canvasDrawableWidth / (sigilWidth == 0 ? 1 : sigilWidth);
    final double scaleY = canvasDrawableHeight / (sigilHeight == 0 ? 1 : sigilHeight);
    final double scale = min(scaleX, scaleY); // Usa a menor escala para não distorcer

    // Calcula o deslocamento para centralizar o desenho no canvas
    final double offsetX = (canvasSize.width - (sigilWidth * scale)) / 2 - (minX * scale);
    final double offsetY = (canvasSize.height - (sigilHeight * scale)) / 2 - (minY * scale);

    // 4. Mapeie os pontos virtuais para as coordenadas reais do canvas
    final List<Offset> finalPoints = virtualPoints.map((p) {
      return Offset(
        p.dx * scale + offsetX,
        p.dy * scale + offsetY,
      );
    }).toList();

    return SigilData(points: finalPoints, color: color);
  }
}
