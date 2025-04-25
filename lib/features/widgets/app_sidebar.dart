import 'package:flutter/material.dart';
import 'package:msu_connect/features/auth/data/services/auth_service.dart';
import 'package:msu_connect/features/services/document_service.dart';
import 'package:msu_connect/features/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'package:msu_connect/features/elearning/presentation/pages/elearning_page.dart';


class AppSidebar extends StatelessWidget {
  final DocumentService documentService = DocumentService();
  final AIService aiService = AIService();

  AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MSU Connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Timetable'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/timetable');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Documents'),
            onTap: () async {
              Navigator.pop(context);
              final documents = await documentService.organizeDocuments();
              Navigator.pushNamed(context, '/documents', arguments: documents);
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI Assistant'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/ai_assistant');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('E-Learning Portal'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ElearningPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                // Get the AIService instance
                final aiService = Provider.of<AIService>(context, listen: false);
                
                // Clear AI service cache
                await aiService.clearCache();
                
                // Logout user
                await Provider.of<AuthService>(context, listen: false).logout();
                
                // Navigate to login screen
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error during logout: ${e.toString()}')),
                );
              }
            },
          ),        ],      ),
    );
  }
}