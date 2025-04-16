import 'package:dio/dio.dart';
import 'package:shared_preferences.dart';

class GoogleClassroomService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://classroom.googleapis.com/v1';
  static const String _tokenKey = 'google_classroom_token';

  Future<void> initialize(String schoolEmail) async {
    // TODO: Implement Google Sign-In and OAuth2 authentication
    // This will require setting up Google Cloud project and OAuth credentials
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$_baseUrl/courses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> courses = response.data['courses'] ?? [];
        return courses.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch courses');
      }
    } catch (e) {
      throw Exception('Failed to fetch courses: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getAssignments(String courseId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$_baseUrl/courses/$courseId/courseWork',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch assignments');
      }
    } catch (e) {
      throw Exception('Failed to fetch assignments: ${e.toString()}');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}