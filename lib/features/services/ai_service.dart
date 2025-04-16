import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  static const String geminiUrl = 'https://gemini.google.com';
  late final WebViewController _controller;
  final ImagePicker _picker = ImagePicker();

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
    // TODO: Implement image processing using ML Kit or similar OCR service
    // This will extract text from the timetable image
    return 'Processed timetable data';
  }

  Future<Map<String, dynamic>> createDigitalTimetable(String extractedText, String degreeProgram) async {
    // TODO: Implement AI processing to structure the timetable data
    // This will create a structured digital timetable based on the extracted text
    return {
      'degree_program': degreeProgram,
      'timetable': [],
    };
  }

  Future<String> saveTimetable(Map<String, dynamic> timetableData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timetable.json');
      await file.writeAsString(timetableData.toString());
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
        return {}; // TODO: Implement proper JSON parsing
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load timetable: ${e.toString()}');
    }
  }
}