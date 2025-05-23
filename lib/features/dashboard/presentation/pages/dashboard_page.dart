import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:msu_connect/core/theme/animations.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/elearning/presentation/pages/elearning_page.dart';
import 'package:msu_connect/features/library/presentation/pages/library_page.dart';
import 'package:msu_connect/features/maps/presentation/pages/map_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/features/timetable/presentation/pages/timetable_page.dart';
import 'package:msu_connect/features/notifications/presentation/pages/notifications_page.dart';
import 'package:msu_connect/features/widgets/dashboard_timetable_widget.dart';
import 'package:msu_connect/features/services/document_service.dart';
import 'package:msu_connect/screens/study_assistant_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;

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
  String _cardNumber = ''; // Default card number
  bool _isFlipped = false;
  
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
        _cardNumber = widget.userData['cardNumber'] ?? '**** **** **** ****';
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
            _cardNumber = data['cardNumber'] ?? '**** **** **** ****';
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

  Future<void> _openDocument(String fileName, String type) async {
    try {
      // Using getDocumentUrl instead of getDocumentDownloadUrl
      final url = await _documentService.getDocumentUrl(fileName, type.toLowerCase());
      if (mounted) {
        // Create a WebViewController first
        final webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url));
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(fileName),
                backgroundColor: AppTheme.msuMaroon,
                foregroundColor: Colors.white,
              ),
              body: WebViewWidget(
                controller: webViewController,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildQuickLinkCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
                icon,
                size: 48,
                color: AppTheme.msuMaroon,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppAnimations.defaultDuration)
      .scale(duration: AppAnimations.defaultDuration);
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

  Widget _buildFrontCard() {
    final user = FirebaseAuth.instance.currentUser;
    final universityName = "Midlands State University";
    final expirationDate = "Exp: 12/25";
    
    return Container(
      key: const ValueKey<bool>(false),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: CardPatternPainter(),
              ),
            ),
          ),
          
          // Card chip
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber.shade300,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // University logo
          Positioned(
            top: 20,
            left: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/msu.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Profile Image
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                  ? Image.network(
                      user.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade900,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue.shade900,
                    ),
              ),
            ),
          ),
          
          // University name
          Positioned(
            top: 100,
            left: 20,
            child: Text(
              universityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Student name
          Positioned(
            top: 125,
            left: 20,
            child: Text(
              _userName.isEmpty ? (user?.displayName ?? 'Student Name') : _userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Program - evenly spaced
          Positioned(
            top: 150,
            left: 20,
            child: Text(
              _userProgram.isEmpty ? 'Degree Program' : _userProgram,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
          
          // Reg Number - evenly spaced
          Positioned(
            top: 170,
            left: 20,
            child: Row(
              children: [
                const Text(
                  "Reg: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userRegNumber.isEmpty ? 'R0000000' : _userRegNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Expiration date
          Positioned(
            bottom: 10,
            left: 20,
            child: Text(
              expirationDate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // CBZ Logo
          Positioned(
            bottom: 15,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  "CBZ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Tap to flip hint
          Positioned(
            bottom: 5,
            right: 5,
            child: Icon(
              Icons.flip,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    final cvv = "123";
    final barcode = _userRegNumber.isEmpty ? "R0000000" : _userRegNumber;
    
    return Container(
      key: const ValueKey<bool>(true),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.blue.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: CardPatternPainter(),
              ),
            ),
          ),
          
          // Magnetic strip
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              color: Colors.black45,
            ),
          ),
          
          // Card number - Added to back of card
          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Card Number:",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Positioned(
            top: 100,
            left: 20,
            child: Text(
              _cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          
          // CVV
          Positioned(
            top: 130,
            right: 30,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  cvv,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // CVV Label
          Positioned(
            top: 130,
            right: 100,
            child: const Text(
              "CVV:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Barcode
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simulated barcode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        30,
                        (index) => Container(
                          width: 2,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: index % 3 == 0 ? Colors.black : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      barcode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // MSU logo watermark
          Positioned(
            top: 140,
            left: 20,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                "assets/msu.png",
                width: 60,
                height: 60,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          
          // CBZ Logo
          Positioned(
            bottom: 15,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  "CBZ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Tap to flip hint
          Positioned(
            bottom: 5,
            right: 5,
            child: Icon(
              Icons.flip,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentIdCard() {
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFlipped = !_isFlipped;
          });
        },
        child: TweenAnimationBuilder(
          tween: Tween<double>(
            begin: 0,
            end: _isFlipped ? 180.0 : 0.0,
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            // Determine which side to show based on the rotation angle
            bool showFront = value < 90;
            
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY((value * math.pi) / 180),
              child: showFront 
                  ? _buildFrontCard()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildBackCard(),
                    ),
            );
          },
        ),
      ),
    ).animate()
      .fadeIn(duration: AppAnimations.defaultDuration)
      .slideY(duration: AppAnimations.defaultDuration, begin: -0.2);
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
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userData: widget.userData)),
              );
              
              // If we got updated data back, refresh the UI
              if (updatedData != null) {
                setState(() {
                  _userName = updatedData['displayName'] ?? '';
                  _userProgram = updatedData['program'] ?? '';
                  _userRegNumber = updatedData['regNumber'] ?? '';
                  _cardNumber = updatedData['cardNumber'] ?? '**** **** **** ****';
                  // Update any other fields that might have changed
                });
              }
            },
          ),
        ],
      ),
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
                      
                      // Student ID Card Section
                      _buildStudentIdCard(),
                      
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
                                'Upload some documents to get started with our BroCode-AI.',
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
                                        onTap: () => _openDocument(fileName, type),
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
                            'Map',
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
                            'E-Library',
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
                            'BroCode AI',
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
                                MaterialPageRoute(builder: (context) => const ElearningPage()),
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
                          ).animate()
                            .fadeIn(duration: AppAnimations.defaultDuration)
                            .scale(duration: AppAnimations.defaultDuration),
                          _buildQuickLinkCard(
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
                      const SizedBox(height: 16),
                      const DashboardTimetableWidget(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// Custom painter for card background pattern
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw a grid pattern
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw some circles for decoration
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      40,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      30,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}