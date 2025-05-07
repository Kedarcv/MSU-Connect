import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/brocode_logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.msuMaroon,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'BROCODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Brocode Zimbabwe',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.msuMaroon,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Innovative Software Solutions',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'About Us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.msuMaroon,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Brocode Zimbabwe is a leading software development company specializing in mobile applications, web development, and custom software solutions. We are dedicated to creating innovative, user-friendly applications that solve real-world problems.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.msuMaroon,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceCard(
                context,
                'Mobile App Development',
                'We create beautiful, functional mobile applications for iOS and Android platforms.',
                Icons.smartphone,
              ),
              _buildServiceCard(
                context,
                'Web Development',
                'Custom websites and web applications built with the latest technologies.',
                Icons.web,
              ),
              _buildServiceCard(
                context,
                'UI/UX Design',
                'User-centered design that enhances user experience and engagement.',
                Icons.design_services,
              ),
              _buildServiceCard(
                context,
                'Software Consulting',
                'Expert advice on software architecture, development, and implementation.',
                Icons.business,
              ),
              _buildServiceCard(
                context,
                'Lead Developer',
                'Michael Mlungisi Nkomo.',
                Icons.business,
              ),
              const SizedBox(height: 32),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.msuMaroon,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactButton(
                context,
                'Website',
                'www.brocodezim.com',
                Icons.language,
                () => _launchUrl('https://www.brocodezim.com'),
              ),
              _buildContactButton(
                context,
                'Email',
                'info@brocodezim.com',
                Icons.email,
                () => _launchUrl('mailto:info@brocodezim.com'),
              ),
              _buildContactButton(
                context,
                'Phone',
                '+263 71 934 0335',
                Icons.phone,
                () => _launchUrl('tel:+263719340335'),
              ),
              const SizedBox(height: 32),
              const Text(
                '© 2025 Brocode Zimbabwe. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.msuMaroon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.msuMaroon,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
