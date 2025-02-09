import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_car_ai_flutter/models/car.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Car>> getScans() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshots = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return snapshots.docs.map((doc) => Car.fromFirestore(doc)).toList();
  }
}
