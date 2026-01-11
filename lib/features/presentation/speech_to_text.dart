import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/ai_response_controller.dart'; // Asegúrate de que el path sea correcto

class SpeechToTextWidget extends ConsumerStatefulWidget {
  const SpeechToTextWidget({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<SpeechToTextWidget> createState() => _SpeechToTextState();
}

class _SpeechToTextState extends ConsumerState<SpeechToTextWidget> {
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          setState(() => _isListening = false);
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: ref.read(animationStateControllerProvider).language == 'en'
          ? 'en_US'
          : 'ja_JP',
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
      onSoundLevelChange: (level) {
        // Aquí puedes usar el level para animar el volumen si quieres
      },
    );

    setState(() => _isListening = true);
    _updateListeningAnimation(true);
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    _updateListeningAnimation(false);

    if (_lastWords.isNotEmpty) {
      // Envía el texto al provider de AI
      // Ajusta el nombre del método según tu AIResponseController (ej: generateResponse, sendMessage, processText, etc.)
      ref
          .read(aiResponseControllerProvider.notifier)
          .generateResponse(_lastWords);
      _lastWords = '';
      debugPrint('Texto enviado a IA: $_lastWords');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      _stopListening();
    }
  }

  void _updateListeningAnimation(bool isListening) {
    // Ajusta el nombre del método según tu AnimationStateController
    // Ejemplos comunes: updateIsListening, setListening, changeListening, updateListening
    // Si no existe ninguno, abre animation_state_controller.dart y agrega:
    // void updateIsListening(bool value) => state = state.copyWith(isListening: value);
    ref
        .read(animationStateControllerProvider.notifier)
        .updateIsListening(isListening);
  }

  @override
  Widget build(BuildContext context) {
    // Escucha la respuesta de la IA (asumiendo que aiResponseControllerProvider es AsyncNotifierProvider<String?> o similar)
    ref.listen<AsyncValue<String?>>(
      aiResponseControllerProvider,
      (previous, next) {
        next.whenData((response) {
          if (response != null && response.isNotEmpty) {
            debugPrint('Respuesta de IA recibida: $response');
            // Aquí puedes reproducir la respuesta con TTS o mostrarla
          }
        });
      },
    );

    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: widget.child ??
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isListening ? Colors.redAccent : Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 40,
            ),
          ),
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
