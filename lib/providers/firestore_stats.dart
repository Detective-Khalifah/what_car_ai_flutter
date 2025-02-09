import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_car_ai_flutter/models/car.dart';

final firestoreStatsProvider =
    StreamProvider.autoDispose<FirestoreStats>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return FirestoreStats(
        totalSaved: 0,
        loading: false,
        isAuthenticated: false,
      );
    }

    // return firestore
    //     .collection('collections')
    //     .where('userId', isEqualTo: user.uid)
    //     .snapshots()
    //     .map((snapshot) {
    //   int totalCars = 0;
    //   for (final doc in snapshot.docs) {
    //     final collection = doc.data();
    //     final int collectionCars = (collection['cars'] as List?)?.length ?? 0;
    //     totalCars += collectionCars;
    //   } this is NEWER (Flutter GPT)

    final snapshots = await firestore
        .collection('collections')
        .where('userId', isEqualTo: user.uid)
        .get();

    int totalCars = 0;
    for (final doc in snapshots.docs) {
      final collection = doc.data();
      final int collectionCars = (collection['cars'] as List?)?.length ?? 0;
      totalCars += collectionCars;
    }

    return FirestoreStats(
      totalSaved: totalCars,
      loading: false,
      isAuthenticated: true,
    );
  });
});
// });

class FirestoreStats {
  final int totalSaved;
  final bool loading;
  final bool isAuthenticated;

  FirestoreStats({
    required this.totalSaved,
    required this.loading,
    required this.isAuthenticated,
  });
}
