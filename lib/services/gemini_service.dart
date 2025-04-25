import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  static GeminiService? _instance;

  // Private constructor for singleton pattern
  GeminiService._() {
    final apiKey = _getApiKey();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  // Factory constructor to get instance
  factory GeminiService() {
    _instance ??= GeminiService._();
    return _instance!;
  }

  // Get API key from environment variables or .env file
  String _getApiKey() {
    // Try to get from environment variables first
    String? apiKey = const String.fromEnvironment('GEMINI_API_KEY');
    
    // If not found, try to get from .env file
    if (apiKey.isEmpty) {
      apiKey = dotenv.env['GEMINI_API_KEY'];
    }
    
    // If still not found, throw an error
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please set GEMINI_API_KEY in your environment variables or .env file.');
    }
    
    return apiKey;
  }

  Future<String> generateResponse(String prompt, {List<File>? files}) async {
  try {
    final content = <Content>[
      Content.text(prompt),
    ];

    if (files != null && files.isNotEmpty) {
      for (final file in files) {
        if (!await file.exists()) continue;

        try {
          final bytes = await file.readAsBytes();
          final mimeType = _getMimeType(file.path);

          if (mimeType.startsWith('image/')) {
            content.add(Content.multi([
              DataPart(mimeType, bytes),
            ]));
          } else if (mimeType.startsWith('text/')) {
            final text = await file.readAsString();
            content.add(Content.text(text));
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing file ${file.path}: $e');
          }
        }
      }
    }

    final response = await _model.generateContent(content);
    return response.text ?? 'No response generated';
  } on GenerativeAIException catch (e) {
    return 'AI Service Error: ${e.message}';
  } catch (e) {
    return 'Error: ${e.toString()}';
  }
}


  }  
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      default:
        return 'application/octet-stream';
    }
  }