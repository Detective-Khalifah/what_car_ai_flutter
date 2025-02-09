import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:what_car_flutter/utils/utilities.dart'; // For formatting

class TipsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.center_focus_strong,
      'title': 'Center the Car',
      'description':
          'Position the vehicle in the middle of your frame for best results',
      'color': Color(0xFF818CF8),
    },
    {
      'icon': Icons.wb_sunny,
      'title': 'Good Lighting',
      'description': 'Ensure adequate lighting for accurate identification',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.straighten,
      'title': 'Multiple Angles',
      'description': 'Try different angles if first scan doesn\'t work',
      'color': Color(0xFF10B981),
    },
    {
      'icon': Icons.photo_camera,
      'title': 'Clear Shot',
      'description': 'Avoid obstacles between camera and vehicle',
      'color': Color(0xFFEC4899),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bestPractices = [
      'Keep steady while scanning',
      'Avoid extreme angles',
      'Scan in daylight when possible',
      'Full car should be visible',
      'Clean lens for better results',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Tips'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to',
                        style: TextStyle(
                            fontSize: 16, color: Colors.white.withOpacity(0.7)),
                      ),
                      Text(
                        'Scan Cars 🚗',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () {
                      // Handle help icon press
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Quick Tips
            _buildTipsSection('Quick Tips', _tips),
            SizedBox(height: 16),
            // Best Practices
            _buildBestPracticesSection('Best Practices', bestPractices),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(String title, List<Map<String, dynamic>> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...tips.map((tip) => _buildTipCard(tip)).toList(),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tip['color'].withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            tip['icon'],
            size: 24,
            color: tip['color'],
          ),
        ),
        title: Text(
          tip['title'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          tip['description'],
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ).animate().fadeIn /*Right*/ (
          delay: Duration(
              milliseconds:
                  int.parse((400 + _tips.indexOf(tip) * 100) as String))),
    );
  }

  Widget _buildBestPracticesSection(String title, List<String> practices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...practices.map((practice) => _buildPracticeItem(practice)).toList(),
      ],
    );
  }

  Widget _buildPracticeItem(String practice, {int index = 0}) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700]),
          ),
        ),
      ),
      title: Text(
        practice,
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    )
        .animate()
        .fadeIn /*Right*/ (delay: Duration(milliseconds: 1000 + index * 100));
  }
}
