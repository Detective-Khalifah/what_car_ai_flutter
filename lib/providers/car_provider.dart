import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:what_car_ai_flutter/constants/driving_tips.dart';
import 'package:what_car_ai_flutter/models/car.dart';

// final carDataProvider =
//     StateNotifierProvider<CarDataProvider, List<Car>>((ref) {
//   return CarDataProvider();
// });

final carDataProvider = StateNotifierProvider<CarDataProvider, CarData>((ref) {
  return CarDataProvider();
});

class CarData {
  // final List<Car> cars;
  final User? user;
  final List<Car> firestoreScans;
  final bool loading;
  final int tipIndex;
  final Map<String, int> stats;

  CarData({
    // required this.cars,
    required this.user,
    required this.firestoreScans,
    required this.loading,
    required this.tipIndex,
    required this.stats,
  });

  CarData copyWith({
    // List<Car>? cars,
    User? user,
    List<Car>? firestoreScans,
    bool? loading,
    int? tipIndex,
    Map<String, int>? stats,
  }) {
    return CarData(
      // cars: cars ?? this.cars,
      user: user ?? this.user,
      firestoreScans: firestoreScans ?? this.firestoreScans,
      loading: loading ?? this.loading,
      tipIndex: tipIndex ?? this.tipIndex,
      stats: stats ?? this.stats,
    );
  }
}

class CarDataProvider extends StateNotifier<CarData> {
  // CarDataProvider() : super([]);
  CarDataProvider()
      : super(CarData(
          // cars: [],
          user: FirebaseAuth.instance.currentUser,
          firestoreScans: [],
          loading: true,
          tipIndex: 0,
          stats: {
            'totalScans': 0,
            'weeklyScans': 0,
            'totalSaved': 0,
            'newSaves': 0,
          },
        )) {
    _fetchFirestoreScans();
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = state.copyWith(user: user);
      _fetchFirestoreScans();
    });
  }

  Future<void> _fetchFirestoreScans() async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(firestoreScans: [], loading: false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('scans')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final scans = snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
      state = state.copyWith(firestoreScans: scans, loading: false);
    } catch (error) {
      print('Error fetching scans: $error');
      state = state.copyWith(loading: false);
    }
  }

  void rotateTip() {
    state =
        state.copyWith(tipIndex: (state.tipIndex + 1) % DRIVING_TIPS.length);
  }

/*
  void addCar(Car car) {
    state = [...state, car];
  }

  void addUser(User user) {
    state = state.copyWith(user: user);
  }

  void addFirestoreScans(List<Car> scans) {
    state = state.copyWith(firestoreScans: scans);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(loading: isLoading);
  }

  void rotateTip() {
    state =
        state.copyWith(tipIndex: (state.tipIndex + 1) % DRIVING_TIPS.length);
  }
  */
}
