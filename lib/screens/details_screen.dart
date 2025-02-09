import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:what_car_ai_flutter/services/scan_service.dart';
import 'package:what_car_ai_flutter/utils/format.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final String carData;
  final bool isFresh;

  const DetailsScreen(
      {super.key, required this.carData, required this.isFresh});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScanService _scanService = ScanService();
  bool _isReady = false;
  int _currentPage = 0;
  bool _isInCollection = false;
  String? _scanId;
  String? _newCollectionName;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final carInfo = json.decode(widget.carData);
      setState(() {
        _images = carInfo['images'];
        _isInCollection = carInfo['isInCollection'];
      });
    } catch (error) {
      print('Error loading car data: $error');
    } finally {
      EasyLoading.dismiss();
      _isReady = true;
    }
  }

  void _handleScroll(double offset) {
    final page = offset ~/ MediaQuery.of(context).size.width;
    setState(() {
      _currentPage = page.toInt();
    });
  }

  void _saveScan() async {
    if (!_auth.currentUser!.uid.isEmpty && widget.isFresh) {
      try {
        final carInfo = json.decode(widget.carData);
        final scanId = await _scanService.saveScan(carInfo, _images[0]);
        setState(() {
          _scanId = scanId;
        });
        print('Scan saved successfully with ID: $_scanId');
      } catch (error) {
        print('Error saving scan: $error');
        Fluttertoast.showToast(msg: 'Failed to save scan');
      }
    }
  }

  void _toggleCollection(String collectionId) async {
    if (_auth.currentUser!.uid.isEmpty) return;

    final carInfo = json.decode(widget.carData);
    final carId = _scanId ?? carInfo['id'];

    try {
      final collectionRef =
          _firestore.collection('collections').doc(collectionId);
      final collectionDoc = await collectionRef.get();
      if (collectionDoc.exists) {
        final updatedCars = collectionDoc
            .data()!['cars']
            .where((car) => car['id'] != carId)
            .toList();
        await collectionRef.update({'cars': updatedCars});
        setState(() {
          _isInCollection = !_isInCollection;
        });
      } else {
        Fluttertoast.showToast(msg: 'Collection not found');
      }
    } catch (error) {
      print('Error toggling collection: $error');
      Fluttertoast.showToast(msg: 'Failed to toggle collection');
    }
  }

  void _createCollection() async {
    if (_auth.currentUser!.uid.isEmpty) return;

    try {
      final newCollection = await _firestore.collection('collections').add({
        'userId': _auth.currentUser!.uid,
        'name': _newCollectionName!,
        'icon': '📁',
        'cars': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isInCollection = true;
      });
      Fluttertoast.showToast(msg: 'Collection created successfully');
    } catch (error) {
      print('Error creating collection: $error');
      Fluttertoast.showToast(msg: 'Failed to create collection');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(json.decode(widget.carData)['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Image Carousel
            ImageSlideshow(
              indicatorColor: Colors.blue,
              indicatorBackgroundColor: Colors.grey,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: _images.map((image) {
                return Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Car Information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  json.decode(widget.carData)['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  json.decode(widget.carData)['category'],
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),

                // Key Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                        'Power', json.decode(widget.carData)['specs']['power']),
                    _buildStat('0-100 km/h',
                        json.decode(widget.carData)['specs']['acceleration']),
                    _buildStat(
                        'Price',
                        formatPrice(
                            json.decode(widget.carData)['specs']['price'])),
                  ],
                ),
                SizedBox(height: 16),

                // Manufacturer & Production Info
                Text(
                  'Manufacturer: ${json.decode(widget.carData)['manufacturer']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Production Years: ${json.decode(widget.carData)['productionYears']}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),

                // Rarity & Match Accuracy
                Text(
                  'Rarity: ${json.decode(widget.carData)['rarity']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Match Accuracy: ${json.decode(widget.carData)['matchAccuracy']}%',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),

                // Description
                Text(
                  'About: ${json.decode(widget.carData)['description']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),

                // Detailed Specifications
                Text(
                  'Specifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...json.decode(widget.carData)['specs'].entries.map((entry) {
                  return Row(
                    children: [
                      Text(
                        '${entry.key.replaceFirst('_', ' ').toUpperCase()}:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text(
                        entry.value is num
                            ? formatPrice(entry.value)
                            : entry.value.toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 16),

                // Also Known As
                Text(
                  'Also Known As',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...json.decode(widget.carData)['alsoKnownAs'].map((name) {
                  return Text(
                    name,
                    style: TextStyle(fontSize: 16),
                  );
                }).toList(),
                SizedBox(height: 16),

                // Similar Images
                Text(
                  'Similar Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ..._images.map((image) {
                  return Image.network(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Save to Collection
              _isInCollection
                  ? IconButton(
                      icon: Icon(Icons.remove_from_queue, color: Colors.red),
                      onPressed: () => _toggleCollection(
                          json.decode(widget.carData)['collectionId']),
                    )
                  : IconButton(
                      icon: Icon(Icons.add_to_queue, color: Colors.green),
                      onPressed: () => _toggleCollection(
                          json.decode(widget.carData)['collectionId']),
                    ),

              // Share
              IconButton(
                icon: Icon(Icons.share, color: Colors.blue),
                onPressed: () {
                  Fluttertoast.showToast(
                      msg:
                          'Sharing feature will be available in the next update!');
                },
              ),

              // Create New Collection
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.purple),
                onPressed: () {
                  showCreateCollectionDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Collection'),
        content: TextField(
          controller: TextEditingController(),
          decoration: InputDecoration(hintText: 'Enter collection name'),
          onChanged: (value) => setState(() => _newCollectionName = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newCollectionName?.trim().isNotEmpty == true) {
                _createCollection();
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
