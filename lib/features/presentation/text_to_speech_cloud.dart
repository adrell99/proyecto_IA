import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/features/data/google_cloud_repository.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:interacting_tom/features/providers/ai_response_controller.dart';
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

      final Uint8List audioBytes = await ref
          .read(synthesizeTextFutureProvider((text, currentLang)).future);

      // Corrección definitiva: usar StreamAudioSource personalizado para bytes
      await player.setAudioSource(
        _BytesAudioSource(audioBytes),
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

    ref.listen<AsyncValue<String?>>(
      aiResponseControllerProvider,
      (previous, next) {
        next.whenData((data) {
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

// Clase personalizada para reproducir bytes con just_audio
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  _BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
