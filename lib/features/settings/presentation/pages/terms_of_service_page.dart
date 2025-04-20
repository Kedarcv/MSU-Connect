import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MSU Connect Terms of Service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.msuMaroon,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: June 2023',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildParagraph(
              'By accessing or using the MSU Connect application ("App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
            ),
            _buildSectionTitle('2. Description of Service'),
            _buildParagraph(
              'MSU Connect is a mobile application designed to provide Midlands State University students with access to university resources, information, and services.',
            ),
            _buildSectionTitle('3. User Accounts'),
            _buildParagraph(
              'To use certain features of the App, you must register for an account using your university credentials. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.',
            ),
            _buildSectionTitle('4. User Conduct'),
            _buildParagraph(
              'You agree not to use the App to:',
            ),
            _buildBulletPoint('Violate any applicable laws or regulations'),
            _buildBulletPoint('Impersonate any person or entity'),
            _buildBulletPoint('Engage in any activity that interferes with or disrupts the App'),
            _buildBulletPoint('Attempt to gain unauthorized access to the App or its related systems'),
            _buildSectionTitle('5. Intellectual Property'),
            _buildParagraph(
              'The App and its original content, features, and functionality are owned by Brocode Zimbabwe and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildSectionTitle('6. Termination'),
            _buildParagraph(
              'We may terminate or suspend your account and access to the App immediately, without prior notice or liability, for any reason.',
            ),
            _buildSectionTitle('7. Changes to Terms'),
            _buildParagraph(
              'We reserve the right to modify or replace these Terms at any time. It is your responsibility to review these Terms periodically for changes.',
            ),
            _buildSectionTitle('8. Contact Us'),
            _buildParagraph(
              'If you have any questions about these Terms, please contact us at:',
            ),
            const SizedBox(height: 8),
            const Text(
              'Brocode Zimbabwe\nEmail: info@brocodezim.com\nWebsite: www.brocodezim.com',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Developed by',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/brocode_logo.png',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'BROCODE ZIMBABWE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.msuMaroon,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.msuMaroon,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}