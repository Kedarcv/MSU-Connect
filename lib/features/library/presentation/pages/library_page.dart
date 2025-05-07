import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  bool _isLoading = true;
  bool _showWebView = false;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            // Show loading indicator
          },
          onPageFinished: (String url) {
            // Hide loading indicator
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
          },
        ),
      )
      ..loadRequest(Uri.parse('https://library.msu.ac.zw'));
  }

  Future<void> _loadBooks() async {
    // Simulate loading books from a service
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _books = [
        {
          'id': '1',
          'title': 'Introduction to Computer Science',
          'author': 'John Smith',
          'category': 'Computer Science',
          'available': true,
          'coverUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '2',
          'title': 'Advanced Database Systems',
          'author': 'Jane Doe',
          'category': 'Computer Science',
          'available': true,
          'coverUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '3',
          'title': 'Software Engineering Principles',
          'author': 'Robert Johnson',
          'category': 'Software Engineering',
          'available': false,
          'coverUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '4',
          'title': 'Artificial Intelligence: A Modern Approach',
          'author': 'Stuart Russell, Peter Norvig',
          'category': 'Artificial Intelligence',
          'available': true,
          'coverUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '5',
          'title': 'Data Structures and Algorithms',
          'author': 'Michael T. Goodrich',
          'category': 'Computer Science',
          'available': true,
          'coverUrl': 'https://via.placeholder.com/150',
        },
      ];
      _filteredBooks = List.from(_books);
      _isLoading = false;
    });
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = List.from(_books);
      } else {
        _filteredBooks = _books
            .where((book) =>
                book['title'].toLowerCase().contains(query.toLowerCase()) ||
                book['author'].toLowerCase().contains(query.toLowerCase()) ||
                book['category'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleWebView() {
    setState(() {
      _showWebView = !_showWebView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showWebView ? Icons.book : Icons.language),
            tooltip: _showWebView ? 'Show Books' : 'MSU Library Website',
            onPressed: _toggleWebView,
          ),
        ],
      ),
      body: _showWebView 
          ? WebViewWidget(controller: _webViewController)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterBooks,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredBooks.isEmpty
                          ? const Center(child: Text('No books found'))
                          : ListView.builder(
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = _filteredBooks[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      book['coverUrl'],
                                      width: 50,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        width: 50,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.book),
                                      ),
                                    ),
                                    title: Text(book['title']),
                                    subtitle: Text('${book['author']} • ${book['category']}'),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: book['available']
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        book['available'] ? 'Available' : 'Borrowed',
                                        style: TextStyle(
                                          color: book['available']
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      // Show book details
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => _buildBookDetails(book),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: _showWebView 
          ? null 
          : FloatingActionButton(
              backgroundColor: AppTheme.msuMaroon,
              foregroundColor: Colors.white,
              onPressed: () {
                // Show categories
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Browse by Category'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Computer Science'),
                          onTap: () {
                            Navigator.pop(context);
                            _filterBooks('Computer Science');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Software Engineering'),
                          onTap: () {
                            Navigator.pop(context);
                            _filterBooks('Software Engineering');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Artificial Intelligence'),
                          onTap: () {
                            Navigator.pop(context);
                            _filterBooks('Artificial Intelligence');
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.category),
            ),
    );
  }

  Widget _buildBookDetails(Map<String, dynamic> book) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              book['coverUrl'],
              height: 150,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            book['title'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Author: ${book['author']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${book['category']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: book['available']
                    ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Book reserved successfully'),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.book_online),
                label: const Text('Reserve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.msuMaroon,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('More Info'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}