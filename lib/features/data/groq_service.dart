import 'package:groq/groq.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para GroqService (Riverpod)
final groqServiceProvider = Provider<GroqService>((ref) {
  final groq = Groq(
    apiKey: const String.fromEnvironment(
        'groqApiKey'), // Obligatorio: flutter run --dart-define=groqApiKey=tu-clave
    configuration: const Configuration(
      model:
          'llama-3.3-70b-versatile', // Recomendado: equilibrio velocidad/calidad
      temperature: 0.7, // Creatividad media
      maxTokens: 512, // Limita respuestas largas
    ),
  );
  return GroqService(groq);
});

class GroqService {
  final Groq _groq;

  GroqService(this._groq) {
    _groq
        .startChat(); // Inicia la sesión persistente (mantiene contexto de conversación)
  }

  /// Obtiene una respuesta completa (no streaming)
  Future<String> getResponse(String prompt) async {
    try {
      final response = await _groq.sendMessage(prompt);
      final content = response.choices.first.message.content;
      return content ?? 'No hay respuesta de Groq';
    } on GroqException catch (e) {
      print('GroqException: ${e.message} - Status: ${e.status}');
      return 'Error con Groq: ${e.message}';
    } catch (e) {
      print('Error inesperado en Groq: $e');
      return 'Error inesperado con Groq: $e';
    }
  }

  /// Streaming: respuesta progresiva (ideal para animar al oso hablando letra por letra)
  Stream<String> streamResponse(String prompt) async* {
    try {
      await for (final chunk in _groq.streamChat(prompt)) {
        final content = chunk.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      }
    } on GroqException catch (e) {
      yield 'Error en streaming: ${e.message}';
    } catch (e) {
      yield 'Error inesperado en streaming: $e';
    }
  }
}
