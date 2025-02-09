import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState {
  String version = "1.0.0";
  String buildNumber = "1";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final version = ref.watch(dataProvider).version;
    // final buildNumber = ref.watch(dataProvider).buildNumber;
    final sections = [
      {
        'title': 'App Details',
        'items': [
          {'label': 'Version', 'value': version},
          {'label': 'Build', 'value': buildNumber},
        ],
      },
      {
        'title': 'Key Features',
        'items': [
          {
            'icon': Icons.auto_awesome,
            'label': 'AI-Powered Recognition',
            'description': 'Instantly identify any car model',
          },
          {
            'icon': Icons.collections,
            'label': 'Smart Collections',
            'description': 'Organize your favorite cars',
          },
          {
            'icon': Icons.history,
            'label': 'Search History',
            'description': 'Track all your car identifications',
          },
          {
            'icon': Icons.photo_camera,
            'label': 'Multi-Angle Detection',
            'description': 'Recognize cars from any angle',
          },
          {
            'icon': Icons.auto_stories,
            'label': 'Detailed Specs',
            'description': 'Access comprehensive car details',
          },
          {
            'icon': Icons.update,
            'label': 'Regular Updates',
            'description': 'New features and car models',
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('About WhatCar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo and Version
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'WhatCar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Version $version',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // App Description
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Your personal car expert powered by artificial intelligence. Point your camera at any car and instantly get detailed information about its make, model, and features.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Sections
              ...sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['title'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...(section['items'] as List<dynamic>).map((item) {
                        if (item.containsKey('value')) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  item['value'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: Icon(
                                item['icon'],
                                size: 24,
                                color: Colors.grey,
                              ),
                              title: Text(
                                item['label'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                item['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
