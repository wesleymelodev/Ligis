import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Modelo para armazenar os dados processados do sigilo.
class SigilData {
  final List<Offset> points;
  final Color color;

  SigilData({required this.points, required this.color});
}

class SigilGenerator {
  // Caracteres suportados para mapeamento
  static const String _charSet = "0123456789abcdefghijklmnopqrstuvwxyz";

  // ================================
  // CONSTANTES ÁUREAS
  // ================================
  static const double _phi = 1.618033988749895;
  static const double _goldenAngle = 360 / (_phi * _phi); // ≈ 137.507764°

  // Parâmetros ajustáveis de escala
  static const double _baseRadius = 10.0;
  static const double _scaleDivisor = 6.0;

  // ================================
  //  MAPEAMENTO DE ÂNGULO E DISTÂNCIA
  // ================================
  static final Map<String, double> _angleMap = {
    for (var i = 0; i < _charSet.length; i++)
      _charSet[i]: (i * _goldenAngle) % 360
  };

  static final Map<String, double> _distanceMap = {
    for (var i = 0; i < _charSet.length; i++)
      _charSet[i]: _baseRadius * pow(_phi, i / _scaleDivisor)
  };

  // ================================
  // Cores associadas a 1–9
  // ================================
  static final Map<int, Color> _colorMap = {
    1: const Color(0xFFFF0000),
    2: const Color(0xFFFFA500),
    3: const Color(0xFFFFFF00),
    4: const Color(0xFF00FF00),
    5: const Color(0xFF00FFFF),
    6: const Color(0xFF0000FF),
    7: const Color(0xFF8500FF),
    8: const Color(0xFFFF00F4),
    9: const Color(0xFFFF0040),
  };

  // ================================
  // 1. Redução da frase
  // ================================
  String _reducePhrase(String text) {
    const String vowels = "aeiouAEIOU";

    String reducedText = text.toLowerCase().split('').where((char) {
      return _charSet.contains(char) && !vowels.contains(char);
    }).join();

    var seen = <String>{};
    return reducedText
        .split('')
        .where((char) => seen.add(char))
        .toList()
        .join('');
  }

  // ================================
  // 2. Hash SHA-256 -> Base 36
  // ================================
  String _generateHash(String text, {int length = 36}) {
    final reducedText = _reducePhrase(text);
    final bytes = utf8.encode(reducedText);
    final digest = sha256.convert(bytes);
    final fullHash = digest.toString();

    String alphanumericHash = '';

    for (int i = 0; i < length && i < fullHash.length; i++) {
      final char = fullHash[i];
      final intValue = int.parse(char, radix: 16);
      alphanumericHash += _charSet[intValue % _charSet.length];
    }

    return alphanumericHash;
  }

  // ================================
  // 3. Cor numerológica
  // ================================
  int _calculatePhraseColorDigit(String text) {
    int letterToNumber(String c) {
      if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
        return ((c.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0)) % 9) + 1;
      } else if (RegExp(r'[0-9]').hasMatch(c)) {
        return int.parse(c);
      }
      return 0;
    }

    int total = text
        .split('')
        .where((c) => RegExp(r'[a-zA-Z0-9]').hasMatch(c))
        .map(letterToNumber)
        .fold(0, (prev, curr) => prev + curr);

    while (total > 9) {
      total = total
          .toString()
          .split('')
          .map(int.parse)
          .fold(0, (prev, curr) => prev + curr);
    }

    return total == 0 ? 9 : total;
  }

  // ================================
  //  GERAÇÃO FINAL DO SIGILO
  // ================================
  SigilData generate(String phrase, Size canvasSize) {
    final hashString = _generateHash(phrase);
    final colorDigit = _calculatePhraseColorDigit(phrase);
    final color = _colorMap[colorDigit] ?? const Color(0xFFFFFFFF);

    List<Offset> virtualPoints = [Offset.zero];
    double currentAngle = 0;

    for (int i = 0; i < hashString.length; i++) {
      final char = hashString[i];

      final dist = _distanceMap[char] ?? 50.0;
      final angleIncrement = _angleMap[char] ?? 0.0;

      currentAngle += angleIncrement;

      final rad = currentAngle * (pi / 180);
      final prevPoint = virtualPoints.last;

      virtualPoints.add(
        Offset(
          prevPoint.dx + dist * cos(rad),
          prevPoint.dy + dist * sin(rad),
        ),
      );
    }

    if (virtualPoints.length < 2) return SigilData(points: [], color: color);

    double minX = virtualPoints.map((p) => p.dx).reduce(min);
    double maxX = virtualPoints.map((p) => p.dx).reduce(max);
    double minY = virtualPoints.map((p) => p.dy).reduce(min);
    double maxY = virtualPoints.map((p) => p.dy).reduce(max);

    final sigilWidth = maxX - minX;
    final sigilHeight = maxY - minY;

    const double padding = 40.0;
    final canvasDrawableWidth = canvasSize.width - padding;
    final canvasDrawableHeight = canvasSize.height - padding;

    final double scaleX = canvasDrawableWidth / (sigilWidth == 0 ? 1 : sigilWidth);
    final double scaleY = canvasDrawableHeight / (sigilHeight == 0 ? 1 : sigilHeight);
    final double scale = min(scaleX, scaleY);

    final double offsetX = (canvasSize.width - (sigilWidth * scale)) / 2 - (minX * scale);
    final double offsetY = (canvasSize.height - (sigilHeight * scale)) / 2 - (minY * scale);

    final List<Offset> finalPoints = virtualPoints.map((p) {
      return Offset(
        p.dx * scale + offsetX,
        p.dy * scale + offsetY,
      );
    }).toList();

    return SigilData(points: finalPoints, color: color);
  }
}