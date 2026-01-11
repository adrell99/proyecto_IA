import 'dart:convert'; // si usas jsonEncode/Decode
import 'package:flutter/foundation.dart'; // para debugPrint
import 'package:http/http.dart' as http;
import 'package:interacting_tom/env/env.dart';

class TextToSpeechApi {
  static const String _baseUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  static Future<Uint8List?> synthesizeSpeech(
      String text, String languageCode) async {
    if (text.trim().isEmpty) return null;

    final apiKey = Env
        .googleCloudApiKey; // ← Cambia 'googleCloudKey' por el nombre real en tu Env.dart
    if (apiKey.isEmpty) {
      debugPrint('Google Cloud API Key no configurada');
      return null;
    }

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final body = jsonEncode({
      'input': {'text': text},
      'voice': {
        'languageCode': languageCode,
        'name':
            languageCode == 'en-US' ? 'en-US-Standard-C' : 'ja-JP-Standard-A',
      },
      'audioConfig': {'audioEncoding': 'MP3'},
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String audioContent = jsonResponse['audioContent'];
        return base64Decode(audioContent);
      } else {
        debugPrint('Error TTS API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error en synthesizeSpeech: $e');
      return null;
    }
  }
}
