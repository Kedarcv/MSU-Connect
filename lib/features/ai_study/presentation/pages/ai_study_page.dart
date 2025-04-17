import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class AiStudyPage extends StatefulWidget {
  const AiStudyPage({super.key});

  @override
  State<AiStudyPage> createState() => _AiStudyPageState();
}

class _AiStudyPageState extends State<AiStudyPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Assistant'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = _chatHistory[index];
                      return _buildChatBubble(
                        message['text']!,
                        message['sender'] == 'user',
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: AppTheme.msuMaroon,
            ),
            const SizedBox(height: 24),
            Text(
              'MSU AI Study Assistant',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.msuMaroon,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about your courses, assignments, or study materials.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Explain database normalization'),
                _buildSuggestionChip('Help with calculus problems'),
                _buildSuggestionChip('Summarize software development lifecycle'),
                _buildSuggestionChip('Tips for writing research papers'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _questionController.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.msuMaroon : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppTheme.msuMaroon,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add({
        'text': question,
        'sender': 'user',
      });
      _isLoading = true;
      _questionController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _chatHistory.add({
          'text': _getAIResponse(question),
          'sender': 'ai',
        });
      });
    });
  }

  String _getAIResponse(String question) {
    // Simple mock responses
    if (question.toLowerCase().contains('database')) {
      return 'Database normalization is the process of structuring a relational database to reduce data redundancy and improve data integrity. It involves organizing fields and tables to minimize duplication of data and prevent anomalies when inserting, updating, or deleting data.';
    } else if (question.toLowerCase().contains('calculus')) {
      return 'For calculus problems, remember to apply the fundamental theorem of calculus when working with integrals and derivatives. Would you like me to help with a specific problem?';
    } else if (question.toLowerCase().contains('software')) {
      return 'The Software Development Life Cycle (SDLC) typically includes: Requirements gathering, Design, Implementation, Testing, Deployment, and Maintenance. Each phase has specific deliverables and activities that feed into the next phase.';
    } else if (question.toLowerCase().contains('research')) {
      return 'When writing research papers, start with a clear thesis statement, conduct thorough research using credible sources, create an outline, write a draft, revise for clarity and coherence, and properly cite all sources using the required citation style (APA, MLA, etc.).';
    } else {
      return 'That\'s an interesting question! As your AI study assistant, I can help you understand concepts, solve problems, and provide study resources. Could you provide more details about what you\'re trying to learn?';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}