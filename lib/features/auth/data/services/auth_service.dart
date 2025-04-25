import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../services/google_classroom_service.dart';
import '../../../services/library_service.dart';
import '../../../services/ai_service.dart';
import '../../../services/document_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://elearning.msu.ac.zw';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final GoogleClassroomService _googleClassroom = GoogleClassroomService();
  final LibraryService _library = LibraryService();
  final AIService _ai = AIService();
  final DocumentService _document = DocumentService();

  get currentUser => null;

  Future<UserModel> login(String email, String password) async {
    try {
      if (!email.endsWith('@students.msu.ac.zw')) {
        throw Exception('Please use your MSU student email');
      }

      final response = await _dio.post(
        '$_baseUrl/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['user'];
        final user = UserModel.fromJson(userData);

        await Future.wait([
          _saveToken(token),
          _saveUser(user),
          _googleClassroom.initialize(email),
          _document.requestStoragePermission(),
        ]);

        return user;
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return UserModel.fromJson({}); // TODO: Implement proper JSON parsing
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
      _googleClassroom.logout(),
      _ai.clearCache(),
    ] as Iterable<Future>);
  }

  Map<String, dynamic> _decodeToken(String token) {
    return JwtDecoder.decode(token);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }
}