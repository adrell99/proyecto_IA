import 'package:openai_dart/openai_dart.dart';

class XaiService {
  final String apiKey =
      const String.fromEnvironment('XAI_API_KEY', defaultValue: '');

  XaiService() {
    if (apiKey.isEmpty) {
      throw Exception(
          'Falta XAI_API_KEY. Ejecuta con --dart-define=XAI_API_KEY=tu_clave');
    }
  }

  Future<String> getResponse(String userPrompt) async {
    final client = OpenAIClient(
      apiKey: apiKey,
      baseUrl: 'https://api.x.ai/v1',
    );

    try {
      final response = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId(
              'grok-beta'), // o el modelo actual de xAI (grok-beta o grok-2 según disponibilidad)
          messages: [
            // System prompt - wrapper .text()
            ChatCompletionMessage.developer(
              content: ChatCompletionDeveloperMessageContent.text(
                'Eres un oso polar muy divertido, sarcástico, ingenioso y amigable con niños. Responde de forma corta, creativa y con humor.',
              ),
            ),

            // User message - wrapper .string()
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(userPrompt),
            ),
          ],
          temperature: 1.0,
          maxCompletionTokens: 400,
        ),
      );

      final content = response.choices.firstOrNull?.message.content?.trim() ??
          '¡Ay no! Grok se quedó pensando en el espacio... 😅';

      return content;
    } catch (e) {
      return '¡Error con xAI! El oso está explorando el universo ($e)';
    }
  }
}
