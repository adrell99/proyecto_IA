import 'package:openai_dart/openai_dart.dart';

class XaiService {
  late final OpenAIClient _client;

  XaiService() {
    _client = OpenAIClient(
      baseUrl: 'https://api.x.ai/v1',
      headers: {
        'Authorization':
            'Bearer ${const String.fromEnvironment('XAI_API_KEY')}',
      },
    );
  }

  /// Respuesta completa (no streaming)
  Future<String> getResponse(String prompt) async {
    try {
      final response = await _client.createChatCompletion(
        request: const CreateChatCompletionRequest(
          // const para prefer_const_constructors
          model: ChatCompletionModel.modelId(
              'grok-beta'), // Cambia a 'grok-4' si tu key lo permite
          messages: [
            const ChatCompletionMessage.developer(
              // content: String directo
              content:
                  'You are Grok, a helpful and maximally truth-seeking AI built by xAI.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.7,
          maxTokens: 1024,
        ),
      );

      // Manejo seguro de nulls (fix unchecked_use_of_nullable_value)
      final content = response.choices.firstOrNull?.message.content;
      return content ?? 'No response received from Grok.';
    } catch (e) {
      // print('xAI error: $e');  // Comenta en producción
      return 'Error contacting xAI: $e';
    }
  }

  /// Streaming progresivo (ideal para animar al oso hablando)
  Stream<String> streamResponse(String prompt) async* {
    try {
      await for (final chunk in _client.createChatCompletionStream(
        request: const CreateChatCompletionRequest(
          // const aquí también
          model: ChatCompletionModel.modelId('grok-beta'),
          messages: [
            const ChatCompletionMessage.developer(
              content: 'You are Grok by xAI.',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.7,
          stream: true,
        ),
      )) {
        final delta = chunk.choices.firstOrNull?.delta.content;
        if (delta != null && delta.isNotEmpty) {
          yield delta;
        }
      }
    } catch (e) {
      // print('xAI streaming error: $e');
      yield 'Error in Grok stream: $e';
    }
  }
}
