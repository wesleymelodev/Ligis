import 'dart:math';
import 'dart:ui'; // Necessário para a classe Color (usada em CustomPainter no Flutter)
import 'package:crypto/crypto.dart'; // Para o hash SHA-256 (garante unicidade visual)
import 'dart:convert'; // Para utf8.encode (conversão de String para Bytes)

/// Modelo para armazenar os dados processados do sigilo.
class SigilData {
  final List<Offset> points; // Lista de coordenadas (X, Y) para as linhas
  final Color color;        // Cor baseada na numerologia da frase

  SigilData({required this.points, required this.color});
}

class SigilGenerator {
  // Caracteres suportados para mapeamento de formas
  static const String _charSet = "0123456789abcdefghijklmnopqrstuvwxyz";

  // Gera um mapa que atribui um ângulo específico (0-360) para cada caractere
  static final Map<String, double> _angleMap = {
    for (var i = 0; i < _charSet.length; i++)
      _charSet[i]: i * (360 / _charSet.length)
  };

  // Gera um mapa que define o comprimento da linha para cada caractere
  static final Map<String, double> _distanceMap = {
    for (var i = 0; i < _charSet.length; i++) _charSet[i]: (i * 3) + 50
  };

  // Cores associadas aos números de 1 a 9 (Cromoterapia/Numerologia)
  static final Map<int, Color> _colorMap = {
    1: const Color(0xFFFF0000), // Vermelho: Energia e Início
    2: const Color(0xFFFFA500), // Laranja: Criatividade
    3: const Color(0xFFFFFF00), // Amarelo: Intelecto
    4: const Color(0xFF008000), // Verde: Estabilidade
    5: const Color(0xFF00FFFF), // Ciano: Mudança
    6: const Color(0xFF0000FF), // Azul: Harmonia
    7: const Color(0xFF8A2BE2), // Roxo: Espiritualidade
    8: const Color(0xFFFFC0CB), // Rosa: Amor/Realização
    9: const Color(0xFF808080), // Cinza: Finalização
  };

  /// 1. Limpa a frase: foca na estrutura retirando o que é redundante
  String _reducePhrase(String text) {
    const String vowels = "aeiouAEIOU";
    // Filtra apenas caracteres válidos do _charSet e remove vogais
    String reducedText = text.toLowerCase().split('').where((char) {
      return _charSet.contains(char) && !vowels.contains(char);
    }).join();

    // Remove letras repetidas para simplificar o traçado mantendo a ordem original
    var seen = <String>{};
    return reducedText
        .split('')
        .where((char) => seen.add(char))
        .toList()
        .join('');
  }

  /// 2. Cria uma sequência de dados determinística via Hash
  String _generateHash(String text, {int length = 36}) {
    final reducedText = _reducePhrase(text); // Usa a frase limpa
    final bytes = utf8.encode(reducedText);  // Converte texto em bytes
    final digest = sha256.convert(bytes);    // Aplica SHA-256 para gerar um ID único
    final fullHash = digest.toString();

    String alphanumericHash = '';
    // Converte o hash hexadecimal em caracteres do nosso _charSet (0-z)
    for (int i = 0; i < length && i < fullHash.length; i++) {
      final char = fullHash[i];
      final intValue = int.parse(char, radix: 16); // Lê o valor Hexa
      alphanumericHash += _charSet[intValue % _charSet.length]; // Mapeia para o set
    }
    return alphanumericHash;
  }

  /// 3. Soma os valores das letras para encontrar a cor correspondente
  int _calculatePhraseColorDigit(String text) {
    int letterToNumber(String c) {
      if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
        // Mapeia letras de A-Z para valores de 1-9 (Tabela Pitagórica)
        return ((c.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0)) % 9) + 1;
      } else if (RegExp(r'[0-9]').hasMatch(c)) {
        return int.parse(c); // Se for número, usa o próprio valor
      }
      return 0;
    }

    // Soma todos os valores convertidos
    int total = text
        .split('')
        .where((c) => RegExp(r'[a-zA-Z0-9]').hasMatch(c))
        .map(letterToNumber)
        .fold(0, (prev, curr) => prev + curr);

    // Redução Teosófica: soma os algarismos até restar apenas um dígito (1-9)
    while (total > 9) {
      total = total
          .toString()
          .split('')
          .map(int.parse)
          .fold(0, (prev, curr) => prev + curr);
    }
    return total == 0 ? 9 : total; // Garante que retorne um índice de cor válido
  }

  /// Gera os pontos finais para desenho, ajustados à tela (Canvas)
  SigilData generate(String phrase, Size canvasSize) {
    final hashString = _generateHash(phrase); // Obtém a "receita" do sigilo
    final colorDigit = _calculatePhraseColorDigit(phrase); // Define a cor
    final color = _colorMap[colorDigit] ?? const Color(0xFFFFFFFF);

    // 1. Converte o hash em vetores (Ângulo + Distância)
    List<Offset> virtualPoints = [Offset.zero]; // Começa no ponto central imaginário (0,0)
    double currentAngle = 0;
    for (int i = 0; i < hashString.length; i++) {
      final char = hashString[i];
      final dist = _distanceMap[char] ?? 50.0;     // Busca distância do caractere
      final angleIncrement = _angleMap[char] ?? 0.0; // Busca ângulo do caractere
      currentAngle += angleIncrement;             // Acumula o ângulo para o próximo ponto

      final rad = currentAngle * (pi / 180);      // Converte para Radianos (necessário para funções Math)
      final prevPoint = virtualPoints.last;       // Pega o último ponto desenhado
      // Calcula a próxima coordenada usando trigonometria
      virtualPoints.add(Offset(
          prevPoint.dx + dist * cos(rad),
          prevPoint.dy + dist * sin(rad)
      ));
    }

    if (virtualPoints.length < 2) return SigilData(points: [], color: color);

    // 2. Localiza as bordas do desenho (Bounding Box)
    double minX = virtualPoints.map((p) => p.dx).reduce(min);
    double maxX = virtualPoints.map((p) => p.dx).reduce(max);
    double minY = virtualPoints.map((p) => p.dy).reduce(min);
    double maxY = virtualPoints.map((p) => p.dy).reduce(max);

    final sigilWidth = maxX - minX;
    final sigilHeight = maxY - minY;

    // 3. Normalização: faz o desenho caber perfeitamente na tela do celular
    const double padding = 40.0; // Margem de segurança para não encostar na borda
    final canvasDrawableWidth = canvasSize.width - padding;
    final canvasDrawableHeight = canvasSize.height - padding;

    // Define o fator de escala mantendo a proporção original do desenho
    final double scaleX = canvasDrawableWidth / (sigilWidth == 0 ? 1 : sigilWidth);
    final double scaleY = canvasDrawableHeight / (sigilHeight == 0 ? 1 : sigilHeight);
    final double scale = min(scaleX, scaleY); // Usa a menor escala para evitar cortes

    // Calcula o deslocamento para centralizar o desenho no meio da tela
    final double offsetX = (canvasSize.width - (sigilWidth * scale)) / 2 - (minX * scale);
    final double offsetY = (canvasSize.height - (sigilHeight * scale)) / 2 - (minY * scale);

    // 4. Aplica a escala e o deslocamento em todos os pontos virtuais
    final List<Offset> finalPoints = virtualPoints.map((p) {
      return Offset(
        p.dx * scale + offsetX,
        p.dy * scale + offsetY,
      );
    }).toList();

    return SigilData(points: finalPoints, color: color);
  }
}