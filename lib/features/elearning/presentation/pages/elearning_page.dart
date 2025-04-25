import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';

class ElearningPage extends StatefulWidget {
  const ElearningPage({super.key});

  @override
  State<ElearningPage> createState() => _ElearningPageState();
}

class _ElearningPageState extends State<ElearningPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  final String _elearningUrl = 'https://elearning.msu.ac.zw';

  @override
  void initState() {
    super.initState();
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
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading page: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(_elearningUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Learning Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _controller.loadRequest(Uri.parse(_elearningUrl)),
            tooltip: 'Go to homepage',
          ),
        ],
      ),
      drawer: AppSidebar(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}