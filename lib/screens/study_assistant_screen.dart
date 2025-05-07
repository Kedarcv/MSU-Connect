import 'dart:io';
import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/webview/presentation/pages/web_view_page.dart';
import 'package:msu_connect/services/gemini_service.dart';

class StudyAssistantScreen extends StatefulWidget {
  const StudyAssistantScreen({super.key});

  @override
  State<StudyAssistantScreen> createState() => _StudyAssistantScreenState();
}

class _StudyAssistantScreenState extends State<StudyAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<File> _selectedFiles = [];
  final List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _userName = '';
  bool _showSuggestions = true;

  // Predefined suggestions for quick prompts
  final List<String> _suggestions = [
    "Explain the concept of machine learning",
    "Help me solve this calculus problem",
    "Summarize this research paper",
    "Create a study plan for my exams",
    "Explain this programming concept"
  ];

  @override
  void initState() {
    super.initState();
    _getUserName();
    // Add initial greeting
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: "Hello, $_userName! How can I help you with your studies today?",
            isUser: false,
            isGreeting: true,
          ));
        });
      }
    });
  }

  void _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() {
        _userName = user.displayName!.split(' ')[0]; // Get first name
      });
    } else {
      setState(() {
        _userName = 'there';
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          for (var path in result.paths.where((path) => path != null)) {
            _selectedFiles.add(File(path!));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _sendMessage([String? predefinedPrompt]) async {
    final prompt = predefinedPrompt ?? _promptController.text.trim();
    if (prompt.isEmpty) return;
    
    setState(() {
      _chatMessages.add(ChatMessage(
        text: prompt,
        isUser: true,
      ));
      _isLoading = true;
      _showSuggestions = false;
    });
    
    _promptController.clear();
    _scrollToBottom();
    
    try {
      // Add typing indicator
      setState(() {
        _chatMessages.add(ChatMessage(
          text: "",
          isUser: false,
          isTyping: true,
        ));
      });
      _scrollToBottom();
      
      final response = await _geminiService.generateResponse(
        prompt,
        files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
      );
      
      // Remove typing indicator and add actual response
      setState(() {
        _chatMessages.removeLast();
        _chatMessages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        _selectedFiles.clear();
      });
    } catch (e) {
      // Remove typing indicator and add error message
      setState(() {
        _chatMessages.removeLast();
        _chatMessages.add(ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _openMsuLibrary() {
    const url = 'https://library.msu.ac.zw';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: url,
          title: 'MSU Library',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(
                Icons.psychology,
                size: 20,
                color: AppTheme.msuMaroon,
              ),
            ),
            const SizedBox(width: 10),
            const Text('BroCode AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _openMsuLibrary,
            tooltip: 'MSU Library',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.msuMaroon.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _chatMessages.isEmpty
                  ? _buildEmptyState()
                  : _buildChatList(),
            ),
            if (_showSuggestions && _chatMessages.length <= 1)
              _buildSuggestionChips(),
            if (_selectedFiles.isNotEmpty)
              _buildSelectedFilesPreview(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.msuMaroon.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 60,
              color: AppTheme.msuMaroon,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BroCode AI Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.msuMaroon,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your personal study companion. Ask me anything about your studies!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openMsuLibrary,
            icon: const Icon(Icons.book),
            label: const Text('Visit MSU Library'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.msuMaroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        
        // Group consecutive AI messages
        bool isFirstInGroup = true;
        bool isLastInGroup = true;
        
        if (!message.isUser && index > 0 && !_chatMessages[index - 1].isUser) {
          isFirstInGroup = false;
        }
        
        if (!message.isUser && index < _chatMessages.length - 1 && !_chatMessages[index + 1].isUser) {
          isLastInGroup = false;
        }
        
        return ChatBubble(
          message: message,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        );
      },
    );
  }

  Widget _buildSuggestionChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((suggestion) {
          return ActionChip(
            label: Text(
              suggestion.length > 30 ? '${suggestion.substring(0, 27)}...' : suggestion,
              style: TextStyle(
                color: AppTheme.msuMaroon,
                fontSize: 12,
              ),
            ),
            backgroundColor: AppTheme.msuMaroon.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.msuMaroon.withOpacity(0.3),
                width: 1,
              ),
            ),
            onPressed: () => _sendMessage(suggestion),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedFilesPreview() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          final fileName = file.path.split('/').last;
          return Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(fileName),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  fileName.length > 15
                      ? '${fileName.substring(0, 12)}...'
                      : fileName,
                  style: const TextStyle(fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _selectedFiles.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.msuMaroon.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFiles,
              tooltip: 'Attach files',
              color: AppTheme.msuMaroon,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.msuMaroon.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Attach image',
              color: AppTheme.msuMaroon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        hintText: 'Ask a question...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      onSubmitted: (_) => _sendMessage(),
                      onTap: () {
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    ),
                  ),
                  _isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.msuMaroon),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: AppTheme.msuMaroon,
                          ),
                          onPressed: _sendMessage,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final bool isError;
  final bool isGreeting;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.isError = false,
    this.isGreeting = false,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const ChatBubble({
    super.key,
    required this.message,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // User messages
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.msuMaroon,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    
    // AI messages
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 50, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirstInGroup)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.msuMaroon.withOpacity(0.2),
                      radius: 16,
                      child: Icon(
                        Icons.psychology,
                        size: 18,
                        color: AppTheme.msuMaroon,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BroCode AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.only(
                left: 16,
                bottom: isLastInGroup ? 16 : 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isError 
                    ? Colors.red[50] 
                    : (message.isGreeting 
                        ? AppTheme.msuMaroon.withOpacity(0.1) 
                        : Colors.grey[100]),
                borderRadius: BorderRadius.only(
                  topLeft: isFirstInGroup ? const Radius.circular(20) : const Radius.circular(5),
                  topRight: const Radius.circular(20),
                  bottomLeft: isLastInGroup ? const Radius.circular(5) : const Radius.circular(5),
                  bottomRight: const Radius.circular(20),
                ),
                border: message.isGreeting 
                    ? Border.all(color: AppTheme.msuMaroon.withOpacity(0.3), width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: message.isTyping
                  ? SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          _buildTypingDot(0),
                          _buildTypingDot(1),
                          _buildTypingDot(2),
                        ],
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: message.isError ? Colors.red : Colors.black87,
                        ),
                        code: const TextStyle(
                          backgroundColor: Color(0xFFf7f7f7),
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFFf7f7f7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        h1: TextStyle(
                          color: AppTheme.msuMaroon,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: AppTheme.msuMaroon,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: AppTheme.msuMaroon,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.msuMaroon,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                      selectable: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Transform.translate(
              offset: Offset(0, sin(value * 3.14 * 2 + index * 1.0) * 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.msuMaroon.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
