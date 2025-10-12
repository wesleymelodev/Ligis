// lib/presentation/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Define um nome de rota estático para fácil acesso.
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    // O Scaffold e a AppBar pegam o estilo do tema automaticamente.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que são Sigilos?',
              // Usando estilos de texto do tema para consistência.
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Um sigilo é um símbolo criado para um propósito mágico específico. Ele é uma representação simbólica de um desejo ou intenção, condensada em uma forma abstrata para que possa ser carregada pelo subconsciente.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Como este App Funciona',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Escreva sua intenção ou desejo no campo de texto.\n\n'
                  '2. O aplicativo remove vogais e letras repetidas para criar a base do sigilo.\n\n'
                  '3. Um hash criptográfico é gerado a partir dessa base, garantindo um padrão único.\n\n'
                  '4. Usando um sistema de ângulos, distâncias e numerologia, o hash é traduzido em um desenho geométrico e uma cor específica, criando seu sigilo pessoal.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
