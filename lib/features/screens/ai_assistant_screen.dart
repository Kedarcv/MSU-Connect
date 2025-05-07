import 'package:flutter/material.dart';
import 'package:msu_connect/features/services/ai_service.dart';
import 'package:msu_connect/features/services/auth_service.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final AIService _aiService = AIService();
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final userEmail = Provider.of<AuthService>(context, listen: false).currentUser?.email ?? '';
    
    try {
      final controller = await _aiService.initializeGeminiWebView(userEmail);
      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing AI assistant: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller?.reload();
            },
          ),
        ],
      ),
      drawer: AppSidebar(userData: {},),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: WebViewWidget(controller: _controller!),
                ),
              ],
            ),
    );
  }
}