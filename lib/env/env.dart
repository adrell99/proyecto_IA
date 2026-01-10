import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get organization => dotenv.env['OPENAI_ORG'] ?? '';
  // Agrega más variables si es necesario
}
