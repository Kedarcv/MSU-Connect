import 'package:flutter/material.dart';
import 'package:msu_connect/features/services/document_service.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  _DocumentListScreenState createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> with SingleTickerProviderStateMixin {
  final DocumentService _documentService = DocumentService();
  Map<String, List<String>> _documents = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final documents = await _documentService.organizeDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading documents: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(String category, String fileName) async {
    try {
      await _documentService.deleteDocument('$category/$fileName');
      
      // Refresh the document list
      await _loadDocuments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: ${e.toString()}')),
      );
    }
  }

  Future<void> _openDocument(String category, String fileName) async {
    try {
      final directory = await _documentService.getLocalPath;
      final filePath = '$directory/$category/$fileName';
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: ${e.toString()}')),
      );
    }
  }

  Widget _buildDocumentList(String category) {
    final documents = _documents[category] ?? [];
    
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${category.substring(0, 1).toUpperCase() + category.substring(1)} Found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
              onPressed: () {
                Navigator.pushNamed(context, '/documents/upload').then((_) => _loadDocuments());
              },
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final fileName = documents[index];
          final extension = path.extension(fileName).toLowerCase();
          
          IconData icon;
          if (extension == '.pdf') {
            icon = Icons.picture_as_pdf;
          } else if (extension == '.doc' || extension == '.docx') {
            icon = Icons.description;
          } else if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
            icon = Icons.image;
          } else if (extension == '.txt') {
            icon = Icons.text_snippet;
          } else {
            icon = Icons.insert_drive_file;
          }
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(icon, color: Theme.of(context).primaryColor),
              title: Text(fileName),
              subtitle: Text('Tap to open'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Document'),
                      content: Text('Are you sure you want to delete "$fileName"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteDocument(category, fileName);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              onTap: () => _openDocument(category, fileName),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notes'),
            Tab(text: 'Exams'),
            Tab(text: 'Timetables'),
            Tab(text: 'Others'),
          ],
        ),
      ),
      drawer: AppSidebar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDocumentList('notes'),
                _buildDocumentList('exams'),
                _buildDocumentList('timetables'),
                _buildDocumentList('others'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/documents/upload').then((_) => _loadDocuments());
        },
        tooltip: 'Upload Document',
        child: const Icon(Icons.add),
      ),
    );
  }
}