import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';
import 'package:what_car_ai_flutter/services/scan_service.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String imageUri;

  const ProcessingScreen({super.key, required this.imageUri});

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScanService _scanService = ScanService();
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    EasyLoading.show(status: 'Processing...');

    try {
      final base64Image = await _getImageBase64(widget.imageUri);
      final carInfo = await _identifyCar(base64Image);

      if (carInfo == null) {
        context.go('/car-not-found', extra: {'imageUri': widget.imageUri});
      } else {
        final user = _auth.currentUser;
        if (user != null) {
          await _saveScan(carInfo, widget.imageUri, base64Image);
        }
        context.go('/details',
            extra: {'carData': jsonEncode(carInfo), 'isFresh': true});
      }
    } catch (error) {
      print('Error processing image: $error');
      context.go('/car-not-found', extra: {'imageUri': widget.imageUri});
    } finally {
      EasyLoading.dismiss();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String> _getImageBase64(String imageUri) async {
    final bytes = await NetworkAssetBundle(Uri.parse(imageUri)).load(imageUri);
    final byteData = bytes.buffer.asUint8List();
    return base64Encode(byteData);
  }

  Future<Car?> _identifyCar(String base64Image) async {
    try {
      final response = null;
      // await _scanService.identifyCar(base64Image); todo: fix error
      if (response.contains('NOT_A_CAR')) {
        return null;
      }
      return jsonDecode(response);
    } catch (error) {
      print('Error identifying car: $error');
      return null;
    }
  }

  Future<void> _saveScan(
      Car carInfo, String imageUri, String base64Image) async {
    try {
      await ref.read(dataProvider.notifier).saveScan(
            carInfo,
            imageUri, /*base64Image todo:fix error*/
          );
    } catch (error) {
      print('Error saving scan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Close Button
          Positioned(
            top: 12,
            left: 4,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Container
                Container(
                  width: screenWidth,
                  height: screenWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Image
                      Image.network(
                        widget.imageUri,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Corners
                      Positioned(top: 0, left: 0, child: _buildCorner()),
                      Positioned(top: 0, right: 0, child: _buildCorner()),
                      Positioned(bottom: 0, left: 0, child: _buildCorner()),
                      Positioned(bottom: 0, right: 0, child: _buildCorner()),
                      // Animated Line
                      if (_isProcessing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: Colors.blue,
                            child: Animate(
                              effects: [
                                MoveEffect(
                                    duration: 4.seconds,
                                    curve: Curves.linear,
                                    begin: Offset(0, -screenHeight * 0.425),
                                    end: Offset(0, screenHeight * 0.425)),
                                FadeEffect(
                                    duration: 2.seconds,
                                    curve: Curves.easeInOut,
                                    begin: 0.6,
                                    end: 1.0),
                              ],
                              child: Container(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Animated Icon
                if (_isProcessing)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Animate(
                      effects: [
                        FadeEffect(
                            duration: Duration(seconds: 1), //1.second,
                            curve: Curves.easeInOut,
                            begin: 0.6,
                            end: 1.0),
                      ],
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: Colors.blue),
          left: BorderSide(width: 2, color: Colors.blue),
        ),
      ),
    );
  }
}
