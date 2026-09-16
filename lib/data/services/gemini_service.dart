import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:note_bite/data/models/flashcard_model.dart';
import 'package:uuid/uuid.dart';

/// Service for interacting with the Gemini API to generate flashcards.
class GeminiService {
  late final Dio _dio;
  late final String _apiKey;
  static const _uuid = Uuid();

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  /// Generates flashcards from a document file using Gemini API.
  ///
  /// Reads the file, sends its content to Gemini with a prompt requesting
  /// structured JSON flashcard data, then parses the response.
  Future<List<FlashcardModel>> generateFlashcards({
    required String filePath,
    required String chapterId,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      // Read file content
      final bytes = await file.readAsBytes();
      final base64Content = base64Encode(bytes);

      // Determine MIME type
      final mimeType = _getMimeType(filePath);

      // Build the request
      final response = await _dio.post(
        '/models/gemini-2.0-flash:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Content,
                  }
                },
                {
                  'text': '''Analyze this document and generate study flashcards from it.
Return ONLY a valid JSON array with no markdown formatting, no code blocks, no extra text.
Each object must have exactly two keys: "front" (the question or term) and "back" (the answer or definition).
Generate between 10 and 25 flashcards that cover the key concepts comprehensively.
Example format: [{"front":"What is X?","back":"X is..."},{"front":"Define Y","back":"Y means..."}]'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 8192,
          }
        },
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response from Gemini API');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List;
      final text = parts[0]['text'] as String;

      // Clean the response text (remove markdown code blocks if present)
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parse JSON
      final List<dynamic> jsonCards = jsonDecode(cleanedText);

      return jsonCards.map((json) {
        return FlashcardModel.fromGeminiJson(
          json as Map<String, dynamic>,
          id: _uuid.v4(),
          chapterId: chapterId,
        );
      }).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Invalid API key. Please check your .env file.');
      }
      throw Exception('API error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }

  /// Returns the MIME type based on file extension.
  String _getMimeType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'md':
        return 'text/markdown';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
