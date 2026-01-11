import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:interacting_tom/env/env.dart'; // Para la key de Google Cloud

/// Provider que sintetiza texto a audio usando Google Cloud Text-to-Speech directamente
final synthesizeTextFutureProvider =
    FutureProvider.family<Uint8List, (String text, String languageCode)>(
  (ref, params) async {
    final text = params.$1;
    final languageCode = params.$2;

    if (text.trim().isEmpty) {
      throw Exception('Texto vacío para TTS');
    }

    final apiKey = Env
        .googleCloudApiKey; // Asegúrate de que este getter exista en env.dart

    if (apiKey.isEmpty) {
      throw Exception('Google Cloud API Key no configurada');
    }

    final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey');

    // Voz simpática para niños
    final voiceName = languageCode.startsWith('en')
        ? 'en-US-Wavenet-C' // Voz masculina amigable
        : 'ja-JP-Wavenet-A'; // Voz femenina (ajusta si tu app usa otros idiomas)

    final body = jsonEncode({
      'input': {'text': text},
      'voice': {
        'languageCode': languageCode,
        'name': voiceName,
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': 0.9,
        'pitch': 1.5,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final String audioContent = json['audioContent'];
      return base64Decode(audioContent);
    } else {
      throw Exception('Error TTS: ${response.statusCode} - ${response.body}');
    }
  },
);
