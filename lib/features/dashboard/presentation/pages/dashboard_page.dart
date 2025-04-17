import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:msu_connect/core/theme/animations.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/maps/presentation/pages/map_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/features/library/presentation/pages/library_page.dart';
import 'package:msu_connect/features/timetable/presentation/pages/timetable_page.dart';
import 'package:msu_connect/features/ai_study/presentation/pages/ai_study_page.dart';
import 'package:msu_connect/features/notifications/presentation/pages/notifications_page.dart';
import 'package:msu_connect/features/classroom/presentation/pages/classroom_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/msu1.png',
          height: 40,
          fit: BoxFit.contain,
        ),
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
      body: SingleChildScrollView(
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
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
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
                              'John Doe',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Computer Science',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                            Text(
                              'Reg: R0123456K',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn(duration: AppAnimations.defaultDuration)
                .slideX(duration: AppAnimations.defaultDuration, begin: -0.2),

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
                        MaterialPageRoute(builder: (context) => const AiStudyPage()),
                      );
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
              _buildScheduleCard(
                context,
                'Database Systems',
                '09:00 AM - 11:00 AM',
                'Room 2.1',
              ),
              const SizedBox(height: 12),
              _buildScheduleCard(
                context,
                'Software Engineering',
                '02:00 PM - 04:00 PM',
                'Lab 3',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Campus Map'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Classroom'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 0) {
            // Already on dashboard
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClassroomPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickLinkCard(
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.class_,
                  color: Theme.of(context).colorScheme.primary,
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
    );
  }
}