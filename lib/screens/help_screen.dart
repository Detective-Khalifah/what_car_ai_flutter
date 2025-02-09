import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      'question': 'How does car recognition work?',
      'answer':
          'Our app uses advanced AI technology to analyze car images. Simply point your camera at any car, and our system will instantly identify the make, model, and year of the vehicle.'
    },
    {
      'question': 'Do I need internet connection?',
      'answer':
          'Yes, an internet connection is required for car recognition as our AI model runs in the cloud.'
    },
    {
      'question': 'How accurate is the recognition?',
      'answer':
          'Our AI model is highly accurate for most modern vehicles. However, accuracy may vary for rare, modified, or classic cars. Clear photos and good lighting will help improve recognition accuracy.'
    },
    {
      'question': 'Can I save cars to collections?',
      'answer':
          'Yes! You can create custom collections to organize cars you\'ve identified. Simply tap the save button after scanning a car, then choose or create a collection to add it to.'
    },
    {
      'question': 'How do I get the best scan results?',
      'answer':
          'For best results:\n• Ensure good lighting\n• Capture the car\'s front or side view\n• Keep the camera steady\n• Avoid extreme angles\n• Make sure the car is clearly visible'
    },
    {
      'question': 'Is my data private?',
      'answer':
          'Yes, we take privacy seriously. Your scan history and collections are stored securely and are only accessible to you. We don\'t share your personal data with third parties.'
    },
    {
      'question': 'Can I use the app in dark conditions?',
      'answer':
          'Yes, you can use the built-in flash feature for low-light conditions. However, for the most accurate results, we recommend scanning cars in well-lit environments.'
    },
    {
      'question': 'How do I update the app?',
      'answer':
          'The app will automatically check for updates when you\'re connected to the internet. You can also manually check for updates through your device\'s app store.'
    },
    {
      'question': 'What if recognition fails?',
      'answer':
          'If recognition fails, try:\n• Taking another photo from a different angle\n• Ensuring better lighting\n• Moving closer to the vehicle\n• Making sure the car is fully in frame'
    },
    {
      'question': 'Can I scan multiple cars at once?',
      'answer':
          'Currently, the app works best when scanning one car at a time. For the most accurate results, focus on a single vehicle in each scan.'
    },
  ];

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frequently Asked Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        faq['question']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _expandedIndex == index
                              ? Colors.purple[700]
                              : Colors.grey[900],
                        ),
                      ),
                      trailing: Icon(
                        _expandedIndex == index
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: _expandedIndex == index
                            ? Colors.purple[700]
                            : Colors.grey[600],
                      ),
                      onTap: () => _toggleExpand(index),
                    ),
                    if (_expandedIndex == index)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          faq['answer']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
