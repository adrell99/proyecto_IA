import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/AIResponseController.dart'; // Asegúrate que este path sea correcto
import 'package:just_audio/just_audio.dart';

class TextToSpeechLocal extends ConsumerStatefulWidget {
  const TextToSpeechLocal({super.key, this.child});
  final Widget? child;

  @override
  ConsumerState<TextToSpeechLocal> createState() => _TextToSpeechState();
}

enum TtsState { playing, stopped, paused, continued }

class _TextToSpeechState extends ConsumerState<TextToSpeechLocal> {
  late FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  TtsState ttsState = TtsState.stopped;
  final player = AudioPlayer(); // Si no lo usas, puedes removerlo

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    flutterTts = FlutterTts();

    await _setAwaitOptions();

    // Logs útiles solo en debug
    if (kDebugMode) {
      final engines = await flutterTts.getEngines;
      debugPrint("Engines: $engines");

      final languages = await flutterTts.getLanguages;
      debugPrint("Languages: $languages");

      final voices = await flutterTts.getVoices;
      debugPrint("Voices: $voices");
    }

    if (isAndroid) {
      await _getDefaultEngine();
      await _getDefaultVoice();
    }

    // Handlers principales (estos siguen funcionando)
    flutterTts.setCompletionHandler(() {
      debugPrint("TTS Complete");
      updateTalkingAnimation(false);
      setState(() => ttsState = TtsState.stopped);
    });

    flutterTts.setCancelHandler(() {
      debugPrint("TTS Cancelled");
      updateTalkingAnimation(false);
      setState(() => ttsState = TtsState.stopped);
    });

    flutterTts.setPauseHandler(() {
      debugPrint("TTS Paused");
      updateTalkingAnimation(false);
      setState(() => ttsState = TtsState.paused);
    });

    flutterTts.setContinueHandler(() {
      debugPrint("TTS Continued");
      setState(() => ttsState = TtsState.continued);
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      updateTalkingAnimation(false);
      setState(() => ttsState = TtsState.stopped);
    });
  }

  void updateTalkingAnimation(bool isTalking) {
    ref.read(animationStateControllerProvider.notifier).updateTalking(isTalking);
  }

  Future<void> _getDefaultEngine() async {
    final engine = await flutterTts.getDefaultEngine;
    if (engine != null && kDebugMode) {
      debugPrint("Default engine: $engine");
    }
  }

  Future<void> _getDefaultVoice() async {
    final voice = await flutterTts.getDefaultVoice;
    if (voice != null && kDebugMode) {
      debugPrint("Default voice: $voice");
    }
  }

  Future<void> _speak(String textToSpeak) async {
    if (textToSpeak.isEmpty) return;

    final currentLang = ref.read(animationStateControllerProvider).language;
    final mapCurLang = currentLang == 'en' ? 'en-US' : 'ja-JP';

    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setLanguage(mapCurLang);

    // Opcional: seleccionar voz específica (descomenta si sabes que existe)
    // final voices = await flutterTts.getVoices;
    // final preferredVoice = voices.firstWhere(
    //   (v) => v['locale'].toString().contains(mapCurLang),
    //   orElse: () => voices.first,
    // );
    // await flutterTts.setVoice(preferredVoice);

    updateTalkingAnimation(true);
    await flutterTts.speak(textToSpeak);
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(
      openAIResponseControllerProvider,
      (previous, next) {
        next.whenData((data) {
          if (data != null && data.isNotEmpty) {
            _speak(data);
            debugPrint('Speaking: $data');
          }
        });
      },
    );

    return widget.child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    flutterTts.stop();
    player.dispose();
    super.dispose();
  }
}