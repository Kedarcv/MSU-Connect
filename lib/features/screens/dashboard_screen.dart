import 'package:flutter/material.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';
import 'package:msu_connect/features/widgets/dashboard_timetable_widget.dart';
import 'package:msu_connect/features/services/document_service.dart';
import 'package:provider/provider.dart';

import '../auth/data/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DocumentService _documentService = DocumentService();
  Map<String, List<String>> _documents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await _documentService.organizeDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSU Connect'),
      ),
      drawer: AppSidebar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadDocuments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                user?.displayName ?? 'MSU Student',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Timetable Widget - Real data, not placeholder
                    const DashboardTimetableWidget(),
                    
                    // Recent Documents
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/documents');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_documents.isEmpty || 
                        (_documents['notes']?.isEmpty ?? true) && 
                        (_documents['exams']?.isEmpty ?? true))
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No documents available. Upload some documents to get started.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: (_documents['notes']?.length ?? 0) + 
                                     (_documents['exams']?.length ?? 0),
                          itemBuilder: (context, index) {
                            String fileName;
                            String type;
                            
                            if (index < (_documents['notes']?.length ?? 0)) {
                              fileName = _documents['notes']![index];
                              type = 'Note';
                            } else {
                              fileName = _documents['exams']![index - (_documents['notes']?.length ?? 0)];
                              type = 'Exam';
                            }
                            
                            return Card(
                              margin: const EdgeInsets.only(right: 16.0),
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          type == 'Note' ? Icons.note : Icons.assignment,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          type,
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        // Open document
                                      },
                                      child: Text(
                                        'Open',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickActionButton(
                                context,
                                Icons.upload_file,
                                'Upload Document',
                                () {
                                  Navigator.pushNamed(context, '/documents/upload');
                                },
                              ),
                              _buildQuickActionButton(
                                context,
                                Icons.calendar_today,
                                'Edit Timetable',
                                () {
                                  Navigator.pushNamed(context, '/timetable');
                                },
                              ),
                              _buildQuickActionButton(
                                context,
                                Icons.smart_toy,
                                'AI Assistant',
                                () {
                                  Navigator.pushNamed(context, '/ai_assistant');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}