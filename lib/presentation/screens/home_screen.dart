import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../core/logic/sigil_generator.dart';
import '../widgets/sigil_display_canvas.dart';
import '../widgets/custom_button.dart'; // 1. Importe o novo botão customizado
import '../widgets/custom_input_field.dart'; // 1. Importe o input customizado
import 'about_screen.dart';
import 'package:universal_html/html.dart' as html;

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final SigilGenerator _sigilGenerator = SigilGenerator();
  SigilData? _sigilData;
  Color? _customColor;
  final GlobalKey _canvasKey = GlobalKey();

  void _showColorPicker() {
    // A cor inicial do picker será a cor customizada ou a cor do sigilo
    Color pickerColor = _customColor ?? _sigilData?.color ?? Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() => _customColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_sigilData == null) return;

    // 1. Obtém o tamanho da área de desenho usando a GlobalKey
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    if (renderBox == null) {
      // Opcional: Mostrar uma mensagem de erro ao usuário se o canvas não for encontrado.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving image: Canvas not found.')),
      );
      return;
    }
    final size = renderBox.size;

    // 2. Cria um "gravador" de imagens
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 3. Desenha o fundo e o sigilo no canvas do gravador
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;

    BackgroundPainter.drawBackground(canvas, size, bgColor);
    SigilPainter.drawSigil(canvas, size, _sigilData, _customColor);


    // 4. Finaliza a gravação e converte para uma imagem
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 5. Usa a biblioteca 'dart:html' para criar e clicar em um link de download
    final base64Encoder = base64.encoder;
    final base64String = base64Encoder.convert(pngBytes);
    final anchor = html.AnchorElement(href: 'data:image/png;base64,$base64String')
      ..setAttribute('download', 'sigil.png')
      ..style.display = 'none';

    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
  }

  @override
  Widget build(BuildContext context) {
    // Verifica qual o brilho do tema atual para decidir o ícone
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligis - Sigil Generator'),
        actions: [
          // Botão para trocar o tema
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: widget.toggleTheme, // Chama a função passada do MyApp
            tooltip: 'Change Theme',
          ),
          // Botão de Informação
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(AboutScreen.routeName);
            },
            tooltip: 'About the App',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInputField(
              controller: _textController,
              hintText: 'Enter your intention here...',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Generate',
                    onPressed: () {
                      // Ao gerar um novo sigilo, resete a cor customizada
                      if (_textController.text.trim().isEmpty) {
                        setState(() {
                          _sigilData = null;
                          _customColor = null;
                        });
                      } else {
                        setState(() {
                          _customColor = null;
                        });
                      }
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                // 5. Botão de cor que só aparece se um sigilo foi gerado
                if (_sigilData != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.color_lens_outlined),
                      tooltip: 'Change Color',
                      onPressed: _showColorPicker,
                      color: _customColor ?? _sigilData!.color,
                    ),
                  ),
                  const SizedBox(width: 8), // Espaçamento entre os botões de ícone
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.save_alt_outlined),
                      tooltip: 'Save Image',
                      onPressed: _saveImage,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ]
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              key: _canvasKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                  final String phrase = _textController.text;

                  // Gera o sigilo somente se houver texto e o botão foi pressionado
                  if (phrase.trim().isNotEmpty) {
                    _sigilData = _sigilGenerator.generate(phrase, canvasSize);
                  } else {
                    _sigilData = null;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      // Define a borda preta apenas no modo claro.
                      border: isDarkMode ? null : Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SigilDisplayCanvas(
                      sigilData: _sigilData,
                      // Define o fundo branco no modo claro e preto no modo escuro.
                      backgroundColor: isDarkMode ? Colors.black : Colors.white,
                      overrideColor: _customColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adiciona um listener para reconstruir a UI enquanto o usuário digita
  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      // Força a reconstrução para que o sigilo seja gerado dinamicamente
      // e o botão de cor apareça/desapareça.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.removeListener(() {});
    _textController.dispose();
    super.dispose();
  }
}