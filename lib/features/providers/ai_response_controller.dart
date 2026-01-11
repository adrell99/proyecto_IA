import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:interacting_tom/features/data/groq_service.dart';
import 'package:interacting_tom/features/data/xai_service.dart';

// Esta línea es OBLIGATORIA para generar el .g.dart
part 'ai_response_controller.g.dart';

enum AiProvider { groq, xai }

// Provider para elegir IA (Groq o xAI)
final selectedAiProvider = StateProvider<AiProvider>((ref) => AiProvider.groq);

// Providers para servicios
final groqServiceProvider = Provider<GroqService>((ref) => GroqService());

final xaiServiceProvider = Provider<XaiService>((ref) => XaiService());

@riverpod
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

  void clearResponse() {
    state = const AsyncData(null);
  }

  // Para compatibilidad con speech_to_text
  Future<void> generateResponse(String text) async {
    await getResponse(text);
  }
}
