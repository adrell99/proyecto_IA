import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart'; // Para el oso animado

// Imports correctos de tus widgets TTS y Speech
import 'package:interacting_tom/features/presentation/text_to_speech_cloud.dart'; // ← TTS Cloud
import 'package:interacting_tom/features/presentation/speech_to_text.dart'; // ← Micrófono

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building Home Screen');

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Animación Rive del oso como fondo
            const Center(
              child: RiveAnimation.asset(
                'assets/bear_character.riv', // ← Asegúrate de que este asset exista en pubspec.yaml
                fit: BoxFit.contain,
              ),
            ),

            // Widget de Speech-to-Text (micrófono interactivo)
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SpeechToTextWidget(), // ← Nombre correcto del widget
              ),
            ),

            // Widget TTS Cloud (voz del oso)
            const TextToSpeechCloud(
              // ← Aquí estaba el error: nombre correcto del widget
              child: SizedBox.shrink(),
            ),

            // Botón de configuración (ejemplo)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor:
                    Colors.purple.withValues(alpha: 0.7), // Fix deprecado
                onPressed: () {
                  // Tu lógica (ej: cambiar idioma o modo Groq/xAI)
                },
                child: const Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
