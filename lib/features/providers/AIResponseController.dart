import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:interacting_tom/features/data/groq_service.dart';
import 'package:interacting_tom/features/data/xai_service.dart';

// ¡IMPORTANTE! Esta línea debe estar exactamente así
part 'AIResponseController.g.dart';

enum AiProvider { groq, xai }

// Provider para seleccionar qué IA usar (Groq o xAI)
final aiProvider = StateProvider<AiProvider>((ref) => AiProvider.groq);

@Riverpod(
    keepAlive: true) // keepAlive: true → no se destruye al cambiar de pantalla
class AiResponseController extends _$AiResponseController {
  @override
  AsyncValue<String?> build() {
    // Estado inicial: null (sin respuesta aún)
    return const AsyncData(null);
  }

  /// Obtiene una respuesta completa (no streaming)
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

  /// Versión con streaming (ideal para animar al oso hablando mientras responde)
  void streamResponse(String prompt) {
    state = const AsyncLoading();

    final provider = ref.read(aiProvider);
    Stream<String> stream;

    if (provider == AiProvider.groq) {
      stream = ref.read(groqServiceProvider).streamResponse(prompt);
    } else {
      stream = ref.read(xaiServiceProvider).streamResponse(prompt);
    }

    // Escuchamos cada chunk y vamos acumulando la respuesta
    stream.listen(
      (chunk) {
        // Actualizamos el estado concatenando el nuevo fragmento
        final current = state.value ?? '';
        state = AsyncData(current + chunk);
      },
      onError: (e, stack) {
        state = AsyncError(e, stack);
      },
      onDone: () {
        // Opcional: puedes hacer algo cuando termine el stream
      },
    );
  }

  // Método útil para limpiar la respuesta actual si lo necesitas
  void clearResponse() {
    state = const AsyncData(null);
  }
}
