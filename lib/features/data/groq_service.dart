import 'package:openai_dart/openai_dart.dart';

class GroqService {
  final String apiKey =
      const String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  GroqService() {
    if (apiKey.isEmpty) {
      throw Exception(
          'Falta GROQ_API_KEY. Ejecuta con --dart-define=GROQ_API_KEY=tu_clave');
    }
  }

  Future<String> getResponse(String userPrompt) async {
    final client = OpenAIClient(
      apiKey: apiKey,
      baseUrl: 'https://api.groq.com/openai/v1',
    );

    try {
      final response = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId(
              'llama-3.1-70b-versatile'), // Modelo rápido y bueno de Groq (puedes cambiarlo)
          messages: [
            // System prompt - sin 'const' + wrapper .text()
            ChatCompletionMessage.developer(
              content: ChatCompletionDeveloperMessageContent.text(
                'Eres un oso polar simpático, juguetón y educativo que habla con niños. Responde corto, divertido y amigable.',
              ),
            ),

            // User message - wrapper .string()
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(userPrompt),
            ),
          ],
          temperature: 0.9,
          maxCompletionTokens: 350,
        ),
      );

      final content = response.choices.firstOrNull?.message.content?.trim() ??
          '¡Ups! El oso se quedó congelado ❄️';

      return content;
    } catch (e) {
      return '¡Error con Groq! El oso se tropezó con un iceberg ($e)';
    }
  }
}
