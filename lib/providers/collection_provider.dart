import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/models/car_collection.dart';
import 'package:what_car_ai_flutter/models/stats.dart';
import 'package:what_car_ai_flutter/services/storage_service.dart';

final dataProvider = StateNotifierProvider<DataProvider, DataState>((ref) {
  return DataProvider();
});

class DataState {
  final List<Car> recentScans;
  final List<Car> savedCollection;
  final bool isLoading;
  final bool isInitialized;
  final bool hasMore;
  final int page;
  final List<CarCollection> collections;
  final Stats stats;
  final User? user;

  DataState({
    this.recentScans = const [],
    this.savedCollection = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.hasMore = true,
    this.page = 0,
    this.collections = const [],
    required Stats stats,
    // this.stats = const {
    //   'totalScans': 0,
    //   'weeklyScans': 0,
    //   'totalSaved': 0,
    //   'newSaves': 0,
    // },
    this.user,
  }) : stats = Stats(
          totalScans: 0,
          weeklyScans: 0,
          totalSaved: 0,
          newSaves: 0,
        );

  // DataState({
  //   required this.recentScans,
  //   required this.savedCollection,
  //   required this.isLoading,
  //   required this.isInitialized,
  //   required this.hasMore,
  //   required this.page,
  //   required this.collections,
  //   required this.stats,
  //   required this.user,
  // });

  DataState copyWith({
    List<Car>? recentScans,
    List<Car>? savedCollection,
    bool? isLoading,
    bool? isInitialized,
    bool? hasMore,
    int? page,
    List<CarCollection>? collections,
    Stats? stats,
    User? user,
  }) {
    return DataState(
      recentScans: recentScans ?? this.recentScans,
      savedCollection: savedCollection ?? this.savedCollection,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      collections: collections ?? this.collections,
      stats: stats ?? this.stats,
      user: user ?? this.user,
    );
  }
}

class DataProvider extends StateNotifier<DataState> {
  DataProvider()
      : super(DataState(
          recentScans: [],
          savedCollection: [],
          isLoading: true,
          isInitialized: false,
          hasMore: true,
          page: 0,
          collections: [
            CarCollection(id: '1', name: 'Favorites', icon: '✨', cars: [])
          ],
          stats: Stats(
            totalScans: 0,
            weeklyScans: 0,
            totalSaved: 0,
            newSaves: 0,
          ),
          // {
          //         'totalScans': 0,
          //         'weeklyScans': 0,
          //         'totalSaved': 0,
          //         'newSaves': 0,
          //       },
          user: null,
        ));

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _auth.currentUser;

      if (user != null) {
        final collectionsSnapshot = await _firestore
            .collection('collections')
            .where('userId', isEqualTo: user.uid)
            .get();
        final collections = collectionsSnapshot.docs
            .map((doc) => CarCollection.fromFirestore(doc))
            .toList();
        state = state.copyWith(collections: collections);
      } else {
        // Load from local storage
        final localCollections = await StorageService().getCollections();
        state = state.copyWith(collections: localCollections);
      }

      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (error) {
      print('Error initializing database: $error');
      state = state.copyWith(isLoading: false, isInitialized: false);
    }
  }

  // Future<void> initialize() async {
  //   try {
  //     state = state.copyWith(isLoading: true);
  //     await _initializeData();
  //     state = state.copyWith(isLoading: false, isInitialized: true);
  //   } catch (error) {
  //     print('Error initializing database: $error');
  //     state = state.copyWith(isLoading: false, isInitialized: false);
  //   }
  // }

  Future<void> _initializeData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final collectionsSnapshot = await _firestore
          .collection('collections')
          .where('userId', isEqualTo: user.uid)
          .get();
      final collections = collectionsSnapshot.docs
          .map((doc) => CarCollection.fromFirestore(doc))
          .toList();
      state = state.copyWith(
        collections: collections,
      );
    } else {
      // Handle local storage when not logged in
    }
  }

  Future<void> loadInitialData() async {
    if (!state.isInitialized) return;
    try {
      state = state.copyWith(isLoading: true);
      final recentScans = await _fetchRecentScans();
      state = state.copyWith(
        recentScans: recentScans,
        isLoading: false,
      );
    } catch (error) {
      print('Error loading initial data: $error');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Car>> _fetchRecentScans() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
    } else {
      return [];
    }
  }

  void setRecentScans(List<Car> scans) {
    state = state.copyWith(recentScans: scans);
  }

  void loadMore() async {
    if (!state.hasMore || state.isLoading || !state.isInitialized) return;
    try {
      state = state.copyWith(isLoading: true);
      final newScans = await _fetchRecentScans();
      state = state.copyWith(
        recentScans: [...state.recentScans, ...newScans],
        hasMore: newScans.length == 10,
        isLoading: false,
      );
    } catch (error) {
      print('Error loading more data: $error');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveScan(Car car, String imageUri) async {
    if (!state.isInitialized) throw Exception('Database not initialized');
    try {
      state = state.copyWith(isLoading: true);
      final scanId = DateTime.now().millisecondsSinceEpoch.toString();
      final newScan = car.copyWith(id: scanId, images: [imageUri]);

      if (state.user != null) {
        await _firestore.collection('scans').add(newScan.toFirestore());
      } else {
        await StorageService().saveScan(newScan);
      }

      await loadInitialData();
    } catch (error) {
      print('Error saving scan: $error');
      throw error;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Future<void> saveScan(Car car, String imageUri) async {
  //   if (!state.isInitialized) throw Exception('Database not initialized');
  //   try {
  //     state = state.copyWith(isLoading: true);
  //     final scanId = DateTime.now().millisecondsSinceEpoch.toString();
  //     final newScan = car.copyWith(
  //         id: scanId, images: [imageUri], timestamp: DateTime.now());
  //     await _firestore.collection('scans').add(newScan.toFirestore());
  //     await loadInitialData();
  //   } catch (error) {
  //     print('Error saving scan: $error');
  //     throw error;
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }

  void toggleSaved(String scanId) async {
    if (!state.isInitialized) return;
    try {
      state = state.copyWith(isLoading: true);
      final scan = state.recentScans.firstWhere((scan) => scan.id == scanId);
      final isSaved = scan.isSaved;
      final updatedScan = scan.copyWith(isSaved: !isSaved);
      await _firestore
          .collection('scans')
          .doc(scanId)
          .update({'isSaved': !isSaved});
      await loadInitialData();
    } catch (error) {
      print('Error toggling saved status: $error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Car>> searchScans(String query) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('scans')
            .where('userId', isEqualTo: user.uid)
            .where('name', isGreaterThanOrEqualTo: query)
            .get();
        return snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
      } else {
        return [];
      }
    } catch (error) {
      print('Error searching scans: $error');
      return [];
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  int totalSavedCars() {
    final uniqueCarIds = <String>{};
    for (final collection in state.collections) {
      for (final car in collection.cars) {
        uniqueCarIds.add(car.id);
      }
    }
    return uniqueCarIds.length;
  }

  Future<void> createCollection(String name) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final newCollection = await _firestore.collection('collections').add({
          'userId': user.uid,
          'name': name,
          'icon': '📁',
          'cars': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        await loadInitialData();
      } else {
        // Local storage logic remains the same
      }
    } catch (error) {
      print('Error creating collection: $error');
    }
  }

  Future<void> addToCollection(String collectionId, Car car) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final collectionRef =
            _firestore.collection('collections').doc(collectionId);
        final collectionDoc = await collectionRef.get();

        if (!collectionDoc.exists) {
          throw Exception('Collection not found');
        }

        final cleanCar = car.toFirestore(); // Ensure the data is clean
        await collectionRef.update({
          'cars': FieldValue.arrayUnion([cleanCar])
        });
      } else {
        // Local storage fallback
        await StorageService().addToCollection(collectionId, car);
      }

      await loadInitialData();
    } catch (error) {
      print('Error adding to collection: $error');
      throw error;
    }
  }

  // Future<void> addToCollection(String collectionId, Car car) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       final collectionRef =
  //           _firestore.collection('collections').doc(collectionId);
  //       final collectionDoc = await collectionRef.get();
  //       if (collectionDoc.exists) {
  //         final updatedCars = [
  //           ...collectionDoc.data()['cars'],
  //           car.toFirestore()
  //         ];
  //         await collectionRef.update({'cars': updatedCars});
  //         await loadInitialData();
  //       } else {
  //         print('Collection not found: $collectionId');
  //       }
  //     } else {
  //       // Local storage logic remains the same
  //     }
  //   } catch (error) {
  //     print('Error adding to collection: $error');
  //   }
  // }

  Future<void> removeFromCollection(String collectionId, String carId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final collectionRef =
            _firestore.collection('collections').doc(collectionId);
        final collectionDoc = await collectionRef.get();
        if (collectionDoc.exists) {
          final updatedCars = collectionDoc
              .data()?['cars']
              .where((car) => car['id'] != carId)
              .toList();
          await collectionRef.update({'cars': updatedCars});
          await loadInitialData();
        } else {
          print('Collection not found: $collectionId');
        }
      } else {
        // Local storage logic remains the same
      }
    } catch (error) {
      print('Error removing from collection: $error');
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      if (collectionId == '1') {
        print('The Favorites collection cannot be deleted');
        return;
      }
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('collections').doc(collectionId).delete();
        await loadInitialData();
      } else {
        // Local storage logic remains the same
      }
    } catch (error) {
      print('Error deleting collection: $error');
    }
  }
}
