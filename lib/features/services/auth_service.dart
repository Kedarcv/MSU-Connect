import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:msu_connect/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Import required services
import '../services/google_classroom_service.dart';
import '../services/library_service.dart';
import '../services/ai_service.dart';
import '../services/document_service.dart';

class AuthService extends ChangeNotifier {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // API related fields
  final Dio _dio = Dio();
  final String _baseUrl = 'https://elearning.msu.ac.zw';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Service instances
  final GoogleClassroomService _googleClassroom = GoogleClassroomService();
  final LibraryService _library = LibraryService();
  final AIService _ai = AIService();
  final DocumentService _document = DocumentService();

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firebase Authentication Methods
  
  // Sign in with email and password using Firebase
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password using Firebase
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password,
    String displayName,
    String program,
    String regNumber,
    String cardNumber,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'displayName': displayName,
        'program': program,
        'regNumber': regNumber,
        'cardNumber': cardNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile in Firebase
  Future<void> updateUserProfile({
    String? displayName,
    String? program,
    String? regNumber,
    String? cardNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update display name in Firebase Auth if provided
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
        
        // Update user document in Firestore
        final userDoc = _firestore.collection('users').doc(user.uid);
        final Map<String, dynamic> updateData = {};
        
        if (displayName != null && displayName.isNotEmpty) {
          updateData['displayName'] = displayName;
        }
        
        if (program != null && program.isNotEmpty) {
          updateData['program'] = program;
        }
        
        if (regNumber != null && regNumber.isNotEmpty) {
          updateData['regNumber'] = regNumber;
        }
        
        if (cardNumber != null && cardNumber.isNotEmpty) {
          updateData['cardNumber'] = cardNumber;
        }
        
        if (updateData.isNotEmpty) {
          await userDoc.update(updateData);
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out from Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // MSU API Authentication Methods
  
  // Login with MSU credentials
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
        await Future.wait<void>([
          _saveToken(token),
          _saveUser(user),
          _googleClassroom.initialize(email),
          _document.requestStoragePermission(),
        ]);
        notifyListeners();
        return user;
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Save user data to shared preferences
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get user from shared preferences
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return UserModel.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  // Get token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Logout from MSU API
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
      _googleClassroom.logout(),
      _ai.clearCache(),
    ]);
    notifyListeners();
  }

  // Decode JWT token
  Map<String, dynamic> _decodeToken(String token) {
    return JwtDecoder.decode(token);
  }

  // Check if user is logged in via MSU API
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  // Check if user is currently logged in
  bool isUserLoggedIn() {
    return currentUser != null;
  }
}
