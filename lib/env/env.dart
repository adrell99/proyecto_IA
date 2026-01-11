import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Keys antiguas de OpenAI (puedes dejarlas o removerlas si no las usas más)
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAiOrganization => dotenv.env['OPENAI_ORG'] ?? '';

  // Nuevas keys para Groq y xAI (las que estás usando ahora)
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get xaiApiKey => dotenv.env['XAI_API_KEY'] ?? '';

  // Key para Google Cloud Text-to-Speech (TTS - la voz del oso)
  static String get googleCloudApiKey =>
      dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? '';
}
