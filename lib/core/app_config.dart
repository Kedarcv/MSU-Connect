import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'MSU Connect';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.msu.ac.zw';
  
  // Feature Flags
  static const bool enableEventsCalendar = true;
  static const bool enableStudentForum = true;
  static const bool enableResourceDirectory = true;
  static const bool enableCourseMaterialSharing = true;
  static const bool enableEmergencyContact = true;

  // Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
    ),
  );

  // Emergency Contact Numbers
  static const Map<String, String> emergencyContacts = {
    'Campus Security': '+263 123 456 789',
    'Health Services': '+263 123 456 790',
    'Student Affairs': '+263 123 456 791',
  };
}