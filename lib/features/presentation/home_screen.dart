import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart'; // Si usas Rive para el oso

// Importa tus widgets
import 'package:interacting_tom/features/presentation/text_to_speech_local.dart';
import 'package:interacting_tom/features/presentation/speech_to_text.dart'; // Este import ahora se usa → adiós unused_import

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializaciones si las tienes
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building Home Screen'); // Cambiado de print

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo o animación Rive del oso (ejemplo)
            const Center(
              child: RiveAnimation.asset(
                'assets/animations/bear.riv', // Ajusta tu archivo Rive
                fit: BoxFit.contain,
              ),
            ),

            // Widget de Speech-to-Text (el micrófono interactivo)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: const Center(
                child: SpeechToTextWidget(), // ← Aquí estaba el error: usa el nombre correcto
              ),
            ),

            // Widget TTS (si lo tienes en overlay o algo)
            const TextToSpeechLocal(
              child: SizedBox.shrink(), // O tu child
            ),

            // Ejemplo de botón con color corregido (sin withOpacity deprecated)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.purple.withValues(alpha: 0.7), // ← Fix deprecado
                onPressed: () {
                  // Tu lógica
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