import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/AIResponseController.dart'; // Corrige este path si es necesario

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
  String _lastError = '';

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
          setState(() {
            _lastError =
                '${error.errorMsg} - ${error.permanent ? 'permanent' : ''}';
            _isListening = false;
          });
        },
      );
      if (_speechEnabled) {
        debugPrint('Speech initialized successfully');
      }
      setState(() {});
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      debugPrint('Speech not enabled');
      return;
    }

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: ref.read(animationStateControllerProvider).language == 'en'
          ? 'en_US'
          : 'ja_JP',
      cancelOnError: false,
      partialResults: true,
      onSoundLevelChange: (level) {
        // Puedes usar esto para animar el oso si quieres
      },
    );

    setState(() => _isListening = true);
    updateListeningAnimation(true);
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    updateListeningAnimation(false);

    // Aquí enviamos el texto reconocido al provider de OpenAI
    if (_lastWords.isNotEmpty) {
      ref.read(openAIResponseControllerProvider.notifier).state =
          _lastWords; // Si es StateProvider
      // O si es AsyncNotifierProvider: ref.read(openAIResponseControllerProvider.notifier).processText(_lastWords);
      debugPrint('Sent to AI: $_lastWords');
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

  void updateListeningAnimation(bool isListening) {
    ref
        .read(animationStateControllerProvider.notifier)
        .updateListening(isListening);
    // Si tienes updateTalking o similar, úsalo aquí también
  }

  @override
  Widget build(BuildContext context) {
    // Escucha cambios en el provider si necesitas reaccionar a respuestas AI
    ref.listen<AsyncValue<String?>>(
      openAIResponseControllerProvider,
      (previous, next) {
        next.whenData((data) {
          if (data != null && data.isNotEmpty) {
            debugPrint('AI response received: $data');
            // Aquí podrías mostrar la respuesta o algo
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
