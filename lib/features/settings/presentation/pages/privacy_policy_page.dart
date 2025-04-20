import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MSU Connect Privacy Policy',
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
            _buildSectionTitle('1. Introduction'),
            _buildParagraph(
              'Brocode Zimbabwe ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use the MSU Connect application ("App").',
            ),
            _buildSectionTitle('2. Information We Collect'),
            _buildParagraph('We may collect the following types of information:'),
            _buildBulletPoint('Personal Information: Name, student ID, email address, and program of study'),
            _buildBulletPoint('Usage Data: Information on how you use the App'),
            _buildBulletPoint('Device Information: Device type, operating system, and browser type'),
            _buildSectionTitle('3. How We Use Your Information'),
            _buildParagraph('We use your information for the following purposes:'),
            _buildBulletPoint('To provide and maintain the App'),
            _buildBulletPoint('To notify you about changes to the App'),
            _buildBulletPoint('To allow you to participate in interactive features'),
            _buildBulletPoint('To provide customer support'),
            _buildBulletPoint('To gather analysis to improve the App'),
            _buildSectionTitle('4. Data Security'),
            _buildParagraph(
              'We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
            ),
            _buildSectionTitle('5. Data Retention'),
            _buildParagraph(
              'We will retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy.',
            ),
            _buildSectionTitle('6. Your Data Protection Rights'),
            _buildParagraph('You have the right to:'),
            _buildBulletPoint('Access your personal data'),
            _buildBulletPoint('Correct inaccurate personal data'),
            _buildBulletPoint('Request deletion of your personal data'),
            _buildBulletPoint('Object to processing of your personal data'),
            _buildBulletPoint('Request restriction of processing your personal data'),
            _buildBulletPoint('Request transfer of your personal data'),
            _buildSectionTitle('7. Changes to This Privacy Policy'),
            _buildParagraph(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            _buildSectionTitle('8. Contact Us'),
            _buildParagraph(
              'If you have any questions about this Privacy Policy, please contact us at:',
            ),
            const SizedBox(height: 8),
            const Text(
              'Brocode Zimbabwe\nEmail: privacy@brocodezim.com\nWebsite: www.brocodezim.com',
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