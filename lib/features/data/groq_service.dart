import 'package:groq/groq.dart';

class GroqService {
  late final Groq _groq;

  GroqService() {
    final config = Configuration(
      model: 'llama3-8b-8192', // o tu modelo preferido, checa docs de Groq
      temperature: 0.7,
      maxTokens: 1024, // si quieres limitar
    );

    _groq = Groq(
      apiKey: const String.fromEnvironment('GROQ_API_KEY'),
      configuration: config, // ← Fix missing_required_argument
    );

    _groq.startChat(); // Inicializa sesión
  }

  Future<String> getResponse(String prompt) async {
    try {
      final response = await _groq.sendMessage(prompt);
      return response.choices.first.message.content ??
          'No response'; // Fix dead_null_aware (lado izquierdo no null real)
    } on GroqException catch (e) {
      // Evita print en prod → usa logger o return error
      // print('Groq error: ${e.message}');  // comenta o quita
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Streaming: no soportado nativo → throw o implementa con http si necesitas
  Stream<String> streamResponse(String prompt) {
    throw UnimplementedError(
        'Groq paquete no soporta streaming nativo. Usa HTTP directo.');
  }
}
