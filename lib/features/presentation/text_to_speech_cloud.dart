import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/features/data/google_cloud_repository.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/AIResponseController.dart';
import 'package:just_audio/just_audio.dart';

class TextToSpeechCloud extends ConsumerStatefulWidget {
  const TextToSpeechCloud({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<TextToSpeechCloud> createState() => _TextToSpeechState();
}

class _TextToSpeechState extends ConsumerState<TextToSpeechCloud> {
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        updateTalkingAnimation(false);
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void updateTalkingAnimation(bool isTalking) {
    ref
        .read(animationStateControllerProvider.notifier)
        .updateTalking(isTalking);
  }

  Future<void> _speakCloudTTS(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final String currentLang =
          ref.read(animationStateControllerProvider).language;

      // Asumiendo que synthesizeTextFutureProvider devuelve Uint8List (bytes de audio)
      final Uint8List audioBytes = await ref
          .read(synthesizeTextFutureProvider(text, currentLang).future);

      // Configurar el audio desde bytes (just_audio soporta DataSource)
      await player.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(audioBytes, mimeType: 'audio/mp3'),
        ),
      );

      updateTalkingAnimation(true);
      await player.play();
    } catch (e) {
      debugPrint('Error in TTS: $e');
      updateTalkingAnimation(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Built text to speech');

    // Escucha la respuesta de la IA (cambiado a aiResponseControllerProvider)
    ref.listen<AsyncValue<String?>>(
      aiResponseControllerProvider,
      (previous, next) {
        // Chequeo seguro contra null
        next?.whenData((data) {
          if (data != null && data.isNotEmpty) {
            _speakCloudTTS(data);
            debugPrint('TTS STATE: $data');
          }
        });
      },
    );

    return widget.child ?? const SizedBox();
  }
}
