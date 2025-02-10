import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': 'Information We Collect',
        'content': [
          'When you use WhatCar, we collect:',
          '• Photos you take for car identification',
          '• Device information for app functionality',
          '• Usage data to improve our service',
          '• Email address (optional, for feedback only)',
        ],
      },
      {
        'title': 'How We Use Your Information',
        'content': [
          'We use your information to:',
          '• Identify cars through our AI system',
          '• Save your car collections locally',
          '• Improve our recognition accuracy',
          '• Enhance app performance',
          '• Respond to your feedback',
        ],
      },
      {
        'title': 'Data Storage',
        'content': [
          '• Car photos are processed in real-time and not stored on our servers',
          '• Your collections are stored securely on our servers',
          '• Scan history is kept securely on our servers',
          // "• You can delete your data anytime through app settings"
        ],
      },
      {
        'title': 'Data Sharing',
        'content': [
          'We do not share your personal information with third parties. Your data is used only for:',
          '• Car identification processing',
          '• App functionality',
          '• Service improvements',
        ],
      },
      {
        'title': 'Camera Usage',
        'content': [
          'WhatCar requires camera access to:',
          '• Capture car images for identification',
          '• Process real-time car recognition',
          'Photos are processed instantly and not stored on our servers.',
        ],
      },
      {
        'title': 'Data Security',
        'content': [
          'We implement security measures to protect your data:',
          '• Secure data transmission',
          '• Local storage encryption',
          '• Regular security updates',
          '• Protected cloud processing',
        ],
      },
      {
        'title': 'Children\'s Privacy',
        'content': [
          'WhatCar is not intended for children under 13. We do not knowingly collect information from children under 13 years of age.',
        ],
      },
      {
        'title': 'Updates to Privacy Policy',
        'content': [
          'We may update this privacy policy occasionally. We will notify you of any significant changes through the app.',
        ],
      },
      {
        'title': 'Contact Us',
        'content': [
          'If you have questions about our privacy policy, please contact us through the Feedback section in the app.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ...sections.map((section) => _buildSection(
                section['title']! as String,
                section["content"]! as List<String>)),
            // .toList(),
            SizedBox(height: 16),
            Text(
              'By using WhatCar, you agree to this privacy policy and our terms of service.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...content.map(
          (text) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ),
        // .toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}
