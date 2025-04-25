import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:msu_connect/core/theme/animations.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/elearning/presentation/pages/elearning_page.dart';
import 'package:msu_connect/features/maps/presentation/pages/map_page.dart';
import 'package:msu_connect/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/features/library/presentation/pages/library_page.dart';
import 'package:msu_connect/features/screens/timetable_screen.dart';
import 'package:msu_connect/features/timetable/presentation/pages/timetable_page.dart';
import 'package:msu_connect/features/notifications/presentation/pages/notifications_page.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';
import 'package:msu_connect/features/widgets/dashboard_timetable_widget.dart';
import 'package:msu_connect/features/services/document_service.dart';
import 'package:msu_connect/screens/study_assistant_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';


class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardPage({
    super.key, 
    required this.userData
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = '';
  String _userProgram = '';
  String _userRegNumber = '';
  
  // Document service integration
  final DocumentService _documentService = DocumentService();
  Map<String, List<String>> _documents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _loadUserData() {
    // First check if data was passed in through widget.userData
    if (widget.userData.isNotEmpty) {
      setState(() {
        _userName = widget.userData['displayName'] ?? '';
        _userProgram = widget.userData['program'] ?? '';
        _userRegNumber = widget.userData['regNumber'] ?? '';
      });
    }
    
    // Then try to load the most up-to-date data from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists && mounted) {
          final data = doc.data() ?? {};
          setState(() {
            _userName = data['displayName'] ?? '';
            _userProgram = data['program'] ?? '';
            _userRegNumber = data['regNumber'] ?? '';
          });
        }
      }).catchError((error) {
        print('Error loading user data: $error');
      });
    }
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Image.asset(
            'assets/msu1.png',
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.msuMaroon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      drawer: AppSidebar(),
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2831108948.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2858763693.
      bottomNavigationBar: MainNavigationPage(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadDocuments();
                _loadUserData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Dashboard Overview'),
                      
                      // Profile Section
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(userData: widget.userData)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.msuMaroon, AppTheme.msuTeal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.msuGold,
                                child: const Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName.isEmpty ? (user?.displayName ?? 'Welcome, Student') : _userName,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      _userProgram.isEmpty ? 'Complete your profile' : _userProgram,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white70,
                                          ),
                                    ),
                                    if (_userRegNumber.isNotEmpty)
                                      Text(
                                        'Reg: $_userRegNumber',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_userName.isEmpty || _userProgram.isEmpty || _userRegNumber.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration)
                        .slideX(duration: AppAnimations.defaultDuration, begin: -0.2),
                      const SizedBox(height: 24),
                      
                      // Timetable Widget
                      const DashboardTimetableWidget(),
                      const SizedBox(height: 24),
                      
                      // Recent Documents Section
                      Text(
                        'Recent Documents',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
                      const SizedBox(height: 16),
                      
                      if (_documents.isEmpty || 
                          (_documents['notes']?.isEmpty ?? true) &&
                          (_documents['exams']?.isEmpty ?? true))
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No documents available. Upload some documents to get started.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ).animate()
                          .fadeIn(duration: AppAnimations.defaultDuration)
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
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
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                            color: AppTheme.msuMaroon,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            type,
                                            style: TextStyle(
                                              color: AppTheme.msuMaroon,
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
                                            color: AppTheme.msuMaroon,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate()
                                .fadeIn(duration: AppAnimations.defaultDuration, delay: Duration(milliseconds: 100 * index));
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick Links Section
                      Text(
                        'Quick Links',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildQuickLinkCard(
                            context,
                            'Campus Map',
                            Icons.map,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MapPage()),
                              );
                            },
                          ),
                          _buildQuickLinkCard(
                            context,
                            'Library',
                            Icons.library_books,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LibraryPage()),
                              );
                            },
                          ),
                          _buildQuickLinkCard(
                            context,
                            'Timetable',
                            Icons.calendar_today,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TimetablePage()),
                              );
                            },
                          ),
                          _buildQuickLinkCard(
                            context,
                            'AI Study Tool',
                            Icons.psychology,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StudyAssistantScreen()),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ELearningPage()),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 48,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'E-Learning Portal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),                          _buildQuickLinkCard(
                            context,
                            'Upload Document',
                            Icons.upload_file,
                            () {
                              Navigator.pushNamed(context, '/documents/upload');
                            },
                          ),
                        ],
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
                      const SizedBox(height: 24),
                      // Schedule Section
                      Text(
                        'Today\'s Schedule',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
            
    
                      const SizedBox(height: 12),
                      _buildScheduleCard(
                        context,
                        'SCHEDULE',
                        'Click to see more',
                        '',
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TimetableScreen()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            context,
                            Icons.smart_toy,
                            'AI Assistant',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StudyAssistantScreen()),
                              );
                            },
                          ),
                        ],
                      ).animate()
                        .fadeIn(duration: AppAnimations.defaultDuration),
                    ],
                  ),
                ),
              ),
            ),
    );
  }  Widget _buildQuickLinkCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.msuMaroon,
              ).animate()
                .scale(duration: AppAnimations.defaultDuration),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
              color: AppTheme.msuMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.msuMaroon,
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
    ).animate()
      .fadeIn(duration: AppAnimations.defaultDuration)
      .scale(duration: AppAnimations.defaultDuration);
  }

  Widget _buildScheduleCard(
    BuildContext context,
    String subject,
    String time,
    String location,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TimetablePage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.msuMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.class_,
                  color: AppTheme.msuMaroon,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppAnimations.defaultDuration)
      .slideX(duration: AppAnimations.defaultDuration, begin: 0.1);
  }
}

class ELearningPage extends StatefulWidget {
  const ELearningPage({super.key});

  @override
  State<ELearningPage> createState() => _ELearningPageState();
}

class _ELearningPageState extends State<ELearningPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  final String _elearningUrl = 'https://e-learning.msu.ac.zw';

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

// Inside the DashboardPage class, add this method:
void _navigateToElearning(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ElearningPage(),
      // This maintains the parent scaffold with bottom navigation bar
      fullscreenDialog: false,
    ),
  );
}