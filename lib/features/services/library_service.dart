import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LibraryService {
  static const String libraryUrl = 'https://library.msu.ac.zw';
  late final WebViewController _controller;

  Future<WebViewController> initializeWebView() async {
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
          onPageFinished: (String url) {
            // Handle page load complete
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource error
          },
        ),
      )
      ..loadRequest(Uri.parse(libraryUrl));

    return _controller;
  }

  Future<void> reload() async {
    await _controller.reload();
  }

  Future<bool> canGoBack() async {
    return await _controller.canGoBack();
  }

  Future<void> goBack() async {
    if (await canGoBack()) {
      await _controller.goBack();
    }
  }

  Future<void> clearCache() async {
    await _controller.clearCache();
    await _controller.clearLocalStorage();
  }
}