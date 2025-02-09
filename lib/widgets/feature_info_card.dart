import 'package:flutter/material.dart';

class FeatureInfoCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  FeatureInfoCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature['label'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              feature['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Confidence: ${feature['confidence'].round()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
