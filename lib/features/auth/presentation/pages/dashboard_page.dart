import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardPage({super.key, required this.userData});

  Future<void> _logout(BuildContext context) async {
    // Clear user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Navigate back to login page and clear navigation stack
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showTimetable(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Timetable'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monday:'),
              Text('• 09:00 - 11:00: Introduction to Programming'),
              Text('• 13:00 - 15:00: Mathematics'),
              SizedBox(height: 8),
              Text('Tuesday:'),
              Text('• 10:00 - 12:00: Data Structures'),
              Text('• 14:00 - 16:00: Physics'),
              SizedBox(height: 8),
              Text('Wednesday:'),
              Text('• 09:00 - 11:00: Database Systems'),
              Text('• 13:00 - 15:00: Computer Networks'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openAIStudyTool(BuildContext context) {
    Navigator.of(context).pushNamed('/ai-study-tool');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSU Connect'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userData["name"] ?? "Student"}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registration: ${userData["regNumber"] ?? "N/A"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Program: ${userData["program"] ?? "N/A"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 24),

              // Quick Links Section
              Text(
                'Quick Links',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _QuickLinkCard(
                    title: 'MSU Website',
                    icon: Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      _launchUrl('https://www.msu.ac.zw/');
                    },
                  ),
                  _QuickLinkCard(
                    title: 'Library',
                    icon: Icons.library_books,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      _launchUrl('https://library.msu.ac.zw/');
                    },
                  ),
                  _QuickLinkCard(
                    title: 'Timetable',
                    icon: Icons.calendar_today,
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () {
                      _showTimetable(context);
                    },
                  ),
                  _QuickLinkCard(
                    title: 'AI Study Tool',
                    icon: Icons.psychology,
                    color: Colors.purple,
                    onTap: () {
                      _openAIStudyTool(context);
                    },
                  ),
                ],
              ).animate().fadeIn().slideY(),

              const SizedBox(height: 24),

              // Schedule Section
              Text(
                'Today\'s Schedule',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('No classes scheduled'),
                  subtitle: const Text('Check your timetable for more details'),
                ),
              ).animate().fadeIn().slideX(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}