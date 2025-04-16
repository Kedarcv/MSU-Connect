import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardPage({super.key, required this.userData});

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
            onPressed: () {
              // TODO: Implement logout
              Navigator.of(context).pop();
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
                      // TODO: Launch MSU website
                    },
                  ),
                  _QuickLinkCard(
                    title: 'Library',
                    icon: Icons.library_books,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      // TODO: Launch library portal
                    },
                  ),
                  _QuickLinkCard(
                    title: 'Timetable',
                    icon: Icons.calendar_today,
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () {
                      // TODO: Show timetable
                    },
                  ),
                  _QuickLinkCard(
                    title: 'AI Study Tool',
                    icon: Icons.psychology,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Launch AI study tool
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