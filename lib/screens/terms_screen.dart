import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': 'Acceptance of Terms',
        'content': [
          'By downloading, installing, or using WhatCar, you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the app.'
        ]
      },
      {
        'title': 'App License',
        'content': [
          'WhatCar grants you a limited, non-exclusive, non-transferable, revocable license to:',
          '• Install and use the app on any device where you\'re signed in with your account',
          '• Access and use the app for personal, non-commercial purposes',
          '• Use the features and services provided within the app according to these terms'
        ]
      },
      {
        'title': 'User Responsibilities',
        'content': [
          'You agree to:',
          '• Use the app in compliance with all applicable laws',
          '• Not modify, reverse engineer, or hack the app',
          '• Not use the app for illegal purposes',
          '• Not interfere with the app\'s security features',
          '• Keep your device secure and updated',
          '• Use the app responsibly and safely'
        ]
      },
      {
        'title': 'Car Recognition Service',
        'content': [
          '• The car recognition feature is provided \'as is\'',
          '• Results are based on AI analysis and may not be 100% accurate',
          '• We do not guarantee the accuracy of identifications',
          '• The service requires an internet connection',
          '• Service availability may vary based on location and conditions'
        ]
      },
      {
        'title': 'User Content',
        'content': [
          'For photos you take using the app:',
          '• You retain ownership of your content',
          '• Photos are processed for identification only',
          '• We don\'t store or share your photos',
          '• You are responsible for the content you capture'
        ]
      },
      {
        'title': 'Intellectual Property',
        'content': [
          '• The app, including its code, design, and content, is protected by copyright',
          '• All trademarks and logos are property of their respective owners',
          '• You may not copy, modify, or distribute app content',
          '• Car brands and models mentioned are properties of their respective manufacturers'
        ]
      },
      {
        'title': 'Limitations of Liability',
        'content': [
          'WhatCar is not liable for:',
          '• Incorrect car identifications',
          '• Service interruptions',
          '• Data loss or device issues',
          '• Indirect or consequential damages',
          '• Issues arising from network connectivity'
        ]
      },
      {
        'title': 'Service Modifications',
        'content': [
          'We reserve the right to:',
          '• Modify or discontinue features',
          '• Update the app and its services',
          '• Change terms and conditions',
          '• Implement new requirements',
          'Changes will be communicated through the app'
        ]
      },
      {
        'title': 'Termination',
        'content': [
          'We may terminate or suspend access to the app:',
          '• For violations of these terms',
          '• To comply with legal requirements',
          '• For security reasons',
          '• At our discretion with reasonable cause'
        ]
      },
      {
        'title': 'Governing Law',
        'content': [
          'These terms are governed by applicable laws. Any disputes shall be resolved in the appropriate jurisdiction.'
        ]
      },
      {
        'title': 'Contact',
        'content': [
          'For questions about these terms, please contact us through the Feedback section in the app.'
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Use',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ...sections
                .map((section) => _buildSection(section['title']! as String,
                    [section['content']! as String]))
                .toList(),
            SizedBox(height: 16),
            Text(
              'By using WhatCar, you acknowledge that you have read and agree to these Terms of Use.',
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
        ...content
            .map((text) => Text(
                  text,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ))
            .toList(),
        SizedBox(height: 16),
      ],
    );
  }
}
