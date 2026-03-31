// lib/services/openai_service.dart
// Equivalente a src/lib/gemini.js

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

class OpenAIService {
  static const String _openAIUrl = 'https://api.openai.com/v1/chat/completions';

  // Equivalente a compressImage() en gemini.js
  // Comprime imagen a máx 600px, calidad 70%
  String compressImage(Uint8List bytes) {
    var image = img.decodeImage(bytes);
    if (image == null) return '';

    const int maxSize = 600;
    if (image.width > image.height && image.width > maxSize) {
      image = img.copyResize(image, width: maxSize);
    } else if (image.height > maxSize) {
      image = img.copyResize(image, height: maxSize);
    }

    final compressed = img.encodeJpg(image, quality: 70);
    final base64Str = base64Encode(compressed);
    return 'data:image/jpeg;base64,$base64Str';
  }

  // Equivalente a invokeGemini()
  Future<dynamic> invoke({
    required String prompt,
    List<String> fileUrls = const [],
    Map<String, dynamic>? responseJsonSchema,
  }) async {
    final apiKey = AppConfig.openAiApiKey;

    // Agrega esquema JSON al prompt si existe
    String finalPrompt = prompt;
    if (responseJsonSchema != null) {
      finalPrompt += '\n\nResponde ÚNICAMENTE con JSON válido sin markdown:\n'
          '${jsonEncode(responseJsonSchema)}';
    }

    // Construye el contenido (texto + imágenes)
    final List<Map<String, dynamic>> content = [
      {'type': 'text', 'text': finalPrompt},
    ];

    for (final url in fileUrls) {
      if (url.startsWith('data:')) {
        content.add({
          'type': 'image_url',
          'image_url': {'url': url, 'detail': 'low'},
        });
      }
    }

    final body = {
      'model': 'gpt-4o',
      'messages': [
        {'role': 'user', 'content': content}
      ],
      'max_tokens': 2048,
      'temperature': 0.7,
    };

    // Equivalente a parseText()
    dynamic parseText(String text) {
      if (responseJsonSchema == null) return text;
      final cleaned = text
          .replaceAll(RegExp(r'```json\n?'), '')
          .replaceAll(RegExp(r'```\n?'), '')
          .trim();
      return jsonDecode(cleaned);
    }

    // Llamada directa a OpenAI si hay API key
    if (apiKey.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(_openAIUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final text = data['choices']?[0]?['message']?['content'] ?? '';
          return parseText(text);
        }
      } catch (e) {
        // Si falla intenta el fallback
      }
    }

    // Equivalente al fallback /api/gemini de Vercel
    // En Flutter apunta a tu backend desplegado
    final backendRes = await http.post(
      Uri.parse('https://agrilux.vercel.app/api/gemini'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'file_urls': fileUrls,
        'response_json_schema': responseJsonSchema,
      }),
    );

    if (backendRes.statusCode != 200) {
      throw Exception('Error ${backendRes.statusCode}');
    }

    final data = jsonDecode(backendRes.body) as Map<String, dynamic>;
    final text = data['choices']?[0]?['message']?['content'] ?? '';
    return parseText(text);
  }
}
