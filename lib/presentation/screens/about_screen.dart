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
        title: const Text('About the App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are Sigils?',
              // Usando estilos de texto do tema para consistência.
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'A sigil is a symbol created for a specific magical purpose. It is a symbolic representation of a desire or intention, condensed into an abstract form so that it can be carried by the subconscious.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'How This App Works',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Write your intention or wish in the text field.\n\n 2. The app removes vowels and repeated letters to create the sigil base.\n\n 3. A cryptographic hash is generated from this base, ensuring a unique pattern.\n\n 4. Using a system of angles, distances, and numerology, the hash is translated into a geometric design and a specific color, creating your personal sigil.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
