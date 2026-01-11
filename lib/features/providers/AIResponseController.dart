import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:interacting_tom/features/data/groq_service.dart';
import 'package:interacting_tom/features/data/xai_service.dart';

// ¡IMPORTANTE! Esta línea debe estar exactamente así
part 'AIResponseController.g.dart';

enum AiProvider { groq, xai }

// Provider para seleccionar qué IA usar (Groq o xAI)
final selectedAiProvider = StateProvider<AiProvider>((ref) => AiProvider.groq);

// Providers para los servicios (instancias singleton)
final groqServiceProvider = Provider<GroqService>((ref) => GroqService());

final xaiServiceProvider = Provider<XaiService>((ref) => XaiService());

@Riverpod(keepAlive: true)
class AiResponseController extends _$AiResponseController {
  @override
  AsyncValue<String?> build() {
    return const AsyncData(null);
  }

  Future<void> getResponse(String prompt) async {
    state = const AsyncLoading();

    final provider = ref.read(selectedAiProvider);

    try {
      String answer;
      if (provider == AiProvider.groq) {
        answer = await ref.read(groqServiceProvider).getResponse(prompt);
      } else {
        answer = await ref.read(xaiServiceProvider).getResponse(prompt);
      }

      state = AsyncData(answer);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void streamResponse(String prompt) {
    state = const AsyncLoading();

    final provider = ref.read(selectedAiProvider);
    Stream<String> stream;

    if (provider == AiProvider.groq) {
      stream = ref.read(groqServiceProvider).streamResponse(prompt);
    } else {
      stream = ref.read(xaiServiceProvider).streamResponse(prompt);
    }

    stream.listen(
      (chunk) {
        final current = state.value ?? '';
        state = AsyncData(current + chunk);
      },
      onError: (e, stack) {
        state = AsyncError(e, stack);
      },
    );
  }

  void clearResponse() {
    state = const AsyncData(null);
  }

  // Método de compatibilidad (para speech_to_text)
  Future<void> generateResponse(String text) async {
    await getResponse(text);
  }
}
