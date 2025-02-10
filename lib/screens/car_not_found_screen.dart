import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarNotFoundScreen extends ConsumerWidget {
  final String imageUri;

  const CarNotFoundScreen({super.key, required this.imageUri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Not Found'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: imageUri,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Not a Car',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The image you provided doesn\'t appear to be a car. Please try again with a photo of a car.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/scan'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Try Another Photo',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.push('/tips'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'View Scanning Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
