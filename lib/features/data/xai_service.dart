import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para XaiService (Riverpod)
final xaiServiceProvider = Provider<XaiService>((ref) {
  final openai = OpenAI.instance
    ..apiKey = const String.fromEnvironment('xaiApiKey') // desde --dart-define
    ..baseUrl = 'https://api.x.ai/v1'; // Endpoint oficial de xAI

  return XaiService(openai);
});

class XaiService {
  final OpenAI _openai;

  XaiService(this._openai);

  Future<String> getResponse(String prompt) async {
    try {
      final completion = await _openai.chat.create(
        model:
            'grok-4', // o 'grok-beta', 'grok-4-fast' – chequea docs.x.ai/models para los actuales
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: prompt,
          ),
        ],
        temperature: 0.7,
        maxTokens: 512,
      );

      final content = completion.choices.first.message.content;
      return content ?? 'No response from xAI Grok';
    } catch (e) {
      print('xAI error: $e');
      return 'Error con xAI Grok: $e';
    }
  }

  // Opcional: Streaming si quieres respuesta progresiva
  Stream<String> streamResponse(String prompt) async* {
    try {
      final stream = await _openai.chat.createStream(
        model: 'grok-4',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: prompt,
          ),
        ],
      );

      await for (final chunk in stream) {
        final content = chunk.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      }
    } catch (e) {
      yield 'Error en streaming xAI: $e';
    }
  }
}
