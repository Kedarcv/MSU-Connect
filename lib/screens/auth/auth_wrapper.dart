import 'package:flutter/material.dart';
import 'package:msu_connect/features/services/auth_service.dart';
import 'package:msu_connect/screens/auth/login_screen.dart';
import 'package:msu_connect/screens/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (_authService.isUserLoggedIn()) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}