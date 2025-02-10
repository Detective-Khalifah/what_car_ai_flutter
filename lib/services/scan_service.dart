import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class ScanService {
  Future<String> saveScan(Map<String, dynamic> carData, String imageUri) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to save scans');
      }

      // Ensure file exists before uploading
      final file = File(imageUri);
      if (!file.existsSync()) {
        throw Exception('Image file not found');
      }

      // Upload image to Firebase Storage
      final imageName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('scans/$imageName');
      // final file = File(imageUri);
      final uploadTask = await storageRef.putFile(file);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Save scan data to Firestore
      final scanRef = await FirebaseFirestore.instance.collection('scans').add({
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName,
        'carData': carData,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Scan saved successfully: ${scanRef.id}');
      return scanRef.id;
    } on FirebaseException catch (e) {
      print('🔥 Firebase Error: ${e.code} - ${e.message}');
      throw Exception('Error saving scan: ${e.message}');
    } catch (error) {
      print('❌ General Error: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserScans() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to get scans');
      }

      final scansSnapshot = await FirebaseFirestore.instance
          .collection('scans')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return scansSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } on FirebaseException catch (e) {
      print('🔥 Firebase Error: ${e.code} - ${e.message}');
      throw Exception('Error fetching scans: ${e.message}');
    } catch (error) {
      print('❌ General Error: $error');
      rethrow;
    }
  }
}
