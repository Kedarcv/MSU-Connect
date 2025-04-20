import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:msu_connect/services/gemini_service.dart';

class AIService {
  static const String geminiUrl = 'https://gemini.google.com';
  late final WebViewController _controller;
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  Future<WebViewController> initializeGeminiWebView(String userEmail) async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            // Handle page load start
          },
          onPageFinished: (String url) async {
            // Auto-fill email if needed
            if (url.contains('signin')) {
              await _controller.runJavaScript(
                'document.querySelector(\'input[type="email"]\').value = "$userEmail";',
              );
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource error
          },
        ),
      )
      ..loadRequest(Uri.parse(geminiUrl));

    return _controller;
  }

  Future<File?> pickTimetableImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<String> processTimetableImage(File image) async {
    // Implement image processing using ML Kit OCR
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = '';
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }
      
      return extractedText;
    } catch (e) {
      return 'Error processing image: ${e.toString()}';
    } finally {
      textRecognizer.close();
    }
  }

  Future<Map<String, dynamic>> createDigitalTimetable(String extractedText, String degreeProgram) async {
    // Use Gemini API to structure the timetable data
    final prompt = '''
    I have a university timetable with the following text extracted from an image. 
    Please convert it into a structured JSON format with the following structure:
    {
      "degree_program": "$degreeProgram",
      "timetable": [
        {
          "day": "Monday",
          "courses": [
            {
              "course_name": "Course Name",
              "course_code": "CODE101",
              "start_time": "09:00",
              "end_time": "10:30",
              "location": "Room 123"
            }
          ]
        }
      ]
    }
    
    Here is the extracted text:
    $extractedText
    
    Only return the JSON, no additional text.
    ''';
    
    try {
      final response = await _geminiService.generateResponse(prompt);
      
      // Extract JSON from the response
      String jsonStr = response;
      // Clean up the response if it contains markdown code blocks
      if (response.contains("")) {
        jsonStr = response.split("json")[1].split("")[0].trim();
      } else if (response.contains("")) {
        jsonStr = response.split("")[1].split("")[0].trim();
      }
      
      // Parse the JSON
      Map<String, dynamic> timetableData = json.decode(jsonStr);
      return timetableData;
    } catch (e) {
      // Return a basic structure if parsing fails
      return {
        'degree_program': degreeProgram,
        'timetable': [],
        'error': 'Failed to parse timetable: ${e.toString()}',
        'raw_text': extractedText
      };
    }
  }

  Future<String> saveTimetable(Map<String, dynamic> timetableData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timetable.json');
      await file.writeAsString(json.encode(timetableData));
      return file.path;
    } catch (e) {
      throw Exception('Failed to save timetable: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> loadTimetable() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timetable.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        // Parse the JSON string back to a Map
        return json.decode(contents);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load timetable: ${e.toString()}');
    }
  }

  Future<void> clearCache() async {
    try {
      await _controller.clearCache();
      await _controller.clearLocalStorage();
      
      // Also clear any saved timetable data
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timetable.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear cache: ${e.toString()}');
    }
  }
}