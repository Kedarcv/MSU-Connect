import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _userEmail;
  String? _userPassword;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
    _initWebView();
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail');
      _userPassword = prefs.getString('userPassword');
    });
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _attemptAutoLogin(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://classroom.google.com/'));
  }

  Future<void> _attemptAutoLogin(String url) async {
    if (!_isLoggedIn && _userEmail != null && _userPassword != null) {
      if (url.contains('accounts.google.com')) {
        // Inject JavaScript to fill in the email field and click next
        await _controller.runJavaScript('''
          setTimeout(function() {
            var emailInput = document.querySelector('input[type="email"]');
            if (emailInput) {
              emailInput.value = '$_userEmail';
              document.querySelector('#identifierNext').click();
            }
          }, 1000);
        ''');

        // Wait for password field to appear and fill it
        await Future.delayed(const Duration(seconds: 2));
        await _controller.runJavaScript('''
          setTimeout(function() {
            var passwordInput = document.querySelector('input[type="password"]');
            if (passwordInput) {
              passwordInput.value = '$_userPassword';
              document.querySelector('#passwordNext').click();
              
              // Set a flag to indicate successful login attempt
              window.localStorage.setItem('msuConnectLoginAttempted', 'true');
            }
          }, 1000);
        ''');

        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Classroom'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.msuMaroon,
              ),
            ),
        ],
      ),
    );
  }
}
