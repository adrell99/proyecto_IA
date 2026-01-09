import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:interacting_tom/features/data/groq_service.dart';
import 'package:interacting_tom/features/data/xai_service.dart';

part 'ai_response_controller.g.dart';

enum AiProvider { groq, xai }

final aiProvider =
    StateProvider<AiProvider>((ref) => AiProvider.groq); // default Groq

@riverpod
class AiResponseController extends _$AiResponseController {
  @override
  AsyncValue<String?> build() {
    return const AsyncData(null);
  }

  Future<void> getResponse(String prompt) async {
    state = const AsyncLoading();

    final provider = ref.read(aiProvider);

    try {
      String answer;
      if (provider == AiProvider.groq) {
        final groqService = ref.read(groqServiceProvider);
        answer = await groqService.getResponse(prompt);
      } else {
        final xaiService = ref.read(xaiServiceProvider);
        answer = await xaiService.getResponse(prompt);
      }

      state = AsyncData(answer);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // Streaming (respuesta progresiva - ideal para animar al oso hablando)
  void streamResponse(String prompt) {
    state = const AsyncLoading();

    final provider = ref.read(aiProvider);

    Stream<String> stream;
    if (provider == AiProvider.groq) {
      stream = ref.read(groqServiceProvider).streamResponse(prompt);
    } else {
      stream = ref.read(xaiServiceProvider).streamResponse(prompt);
    }

    stream.listen(
      (chunk) {
        state = AsyncData((state.value ?? '') + chunk);
      },
      onError: (e, stack) {
        state = AsyncError(e, stack);
      },
    );
  }
}
