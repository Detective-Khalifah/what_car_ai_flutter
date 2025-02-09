// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// // import 'package:what_car_flutter/services/storage_service.dart';
// // import 'package:what_car_flutter/models/car.dart';
// import 'package:intl/intl.dart';
// import 'package:what_car_ai_flutter/models/car.dart';
// import 'package:what_car_ai_flutter/services/storage_service.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // For date formatting
// // import 'package:what_car_flutter/models/car.dart';
// // import 'package:what_car_flutter/services/storage_service.dart';

// final dataProvider = StateNotifierProvider<DataProvider, DataState>((ref) {
//   return DataProvider(ref);
// });

// class DataState {
//   final List<Car> recentScans;
//   final List<Car> savedCollection;
//   final bool isLoading;
//   final bool isInitialized;
//   final bool hasMore;
//   final int page;
//   final List<Map<String, dynamic>> collections;
//   final Map<String, int> stats;
//   final User? user;

//   DataState({
//     required this.recentScans,
//     required this.savedCollection,
//     required this.isLoading,
//     required this.isInitialized,
//     required this.hasMore,
//     required this.page,
//     required this.collections,
//     required this.stats,
//     required this.user,
//   });

//   DataState copyWith({
//     List<Car>? recentScans,
//     List<Car>? savedCollection,
//     bool? isLoading,
//     bool? isInitialized,
//     bool? hasMore,
//     int? page,
//     List<Map<String, dynamic>>? collections,
//     Map<String, int>? stats,
//     User? user,
//   }) {
//     return DataState(
//       recentScans: recentScans ?? this.recentScans,
//       savedCollection: savedCollection ?? this.savedCollection,
//       isLoading: isLoading ?? this.isLoading,
//       isInitialized: isInitialized ?? this.isInitialized,
//       hasMore: hasMore ?? this.hasMore,
//       page: page ?? this.page,
//       collections: collections ?? this.collections,
//       stats: stats ?? this.stats,
//       user: user ?? this.user,
//     );
//   }
// }

// class DataProvider extends StateNotifier<DataState> {
//   final WidgetRef _ref;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final StorageService _storage = StorageService();
//   final String _itemsPerPage = '20';

//   DataProvider(this._ref)
//       : super(DataState(
//           recentScans: [],
//           savedCollection: [],
//           isLoading: true,
//           isInitialized: false,
//           hasMore: true,
//           page: 0,
//           collections: [
//             {
//               'id': '1',
//               'name': 'Favorites',
//               'icon': '✨',
//               'cars': [],
//             }
//           ],
//           stats: {
//             'totalScans': 0,
//             'weeklyScans': 0,
//             'totalSaved': 0,
//             'newSaves': 0,
//           },
//           user: null,
//         ));

//   Future<void> init() async {
//     try {
//       state = state.copyWith(isLoading: true);
//       await _storage.initDatabase();
//       final [initialScans, savedScans, loadedCollections, stats] =
//           await Future.wait([
//         _storage.getRecentScans(int.parse(_itemsPerPage), 0),
//         _storage.getSavedCollection(),
//         _storage.getCollections(),
//         _storage.getStats(),
//       ]);
//       state = state.copyWith(
//         recentScans: initialScans,
//         savedCollection: savedScans,
//         collections: loadedCollections,
//         stats: stats,
//         hasMore: initialScans.length == int.parse(_itemsPerPage),
//         isLoading: false,
//         isInitialized: true,
//       );
//     } catch (error) {
//       print('Error initializing database: $error');
//       state = state.copyWith(isLoading: false, isInitialized: false);
//     }
//   }

//   void listenForAuthStateChanges() {
//     _auth.authStateChanges().listen((user) {
//       state = state.copyWith(user: user);
//       if (user != null) {
//         _fetchCollections();
//       } else {
//         _fetchLocalCollections();
//       }
//     });
//   }

//   Future<void> _fetchCollections() async {
//     try {
//       final collectionsRef = _firestore.collection('collections');
//       final snapshot = await collectionsRef
//           .where('userId', isEqualTo: state.user!.uid)
//           .get();
//       if (snapshot.docs.isEmpty) {
//         await collectionsRef.add({
//           'userId': state.user!.uid,
//           'name': 'Favorites',
//           'icon': '✨',
//           'cars': [],
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       }
//       final collections = snapshot.docs
//           .map((doc) => {
//                 'id': doc.id,
//                 'data': doc.data(),
//               })
//           .toList();
//       state = state.copyWith(collections: collections);
//     } catch (error) {
//       print('Error fetching collections: $error');
//     }
//   }

//   Future<void> _fetchLocalCollections() async {
//     try {
//       final localCollections = await _storage.getCollections();
//       state = state.copyWith(collections: localCollections);
//     } catch (error) {
//       print('Error fetching local collections: $error');
//     }
//   }

//   Future<void> loadInitialData() async {
//     state = state.copyWith(page: 0);
//     await loadData();
//   }

//   Future<void> loadData() async {
//     if (!state.isInitialized) return;
//     try {
//       state = state.copyWith(isLoading: true);
//       final [scans, saved] = await Future.wait([
//         _storage.getRecentScans(
//             int.parse(_itemsPerPage), state.page * int.parse(_itemsPerPage)),
//         _storage.getSavedCollection(),
//       ]);
//       if (state.page == 0) {
//         state = state.copyWith(recentScans: scans, savedCollection: saved);
//       } else {
//         state = state.copyWith(
//             recentScans: [...state.recentScans, ...scans],
//             savedCollection: saved);
//       }
//       state = state.copyWith(
//           hasMore: scans.length == int.parse(_itemsPerPage), isLoading: false);
//     } catch (error) {
//       print('Error loading data: $error');
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   Future<void> loadMore() async {
//     if (!state.hasMore || state.isLoading || !state.isInitialized) return;
//     state = state.copyWith(page: state.page + 1);
//     await loadData();
//   }

//   Future<Car> saveScan(
//       Map<String, dynamic> carInfo, String imageUri, String base64Image) async {
//     if (!state.isInitialized) throw Exception('Database not initialized');
//     try {
//       state = state.copyWith(isLoading: true);
//       final scanId = DateTime.now().millisecondsSinceEpoch.toString();
//       final savedImageUri = await _storage.saveImage(base64Image, scanId);
//       final newScan = Car(
//         id: scanId,
//         manufacturer: carInfo['manufacturer'],
//         name: carInfo['name'],
//         relativeTime: getRelativeTime(DateTime.now().millisecondsSinceEpoch),
//         rarity: carInfo['rarity'],
//         matchAccuracy: carInfo['matchAccuracy'],
//         power: carInfo['specs']['power'],
//         acceleration: carInfo['specs']['acceleration'],
//         images: [savedImageUri],
//       );
//       await _storage.saveScan(newScan.toJson());
//       await loadInitialData();
//       return newScan;
//     } catch (error) {
//       print('Error saving scan: $error');
//       rethrow;
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   Future<bool> toggleSaved(String scanId) async {
//     if (!state.isInitialized) return false;
//     try {
//       state = state.copyWith(isLoading: true);
//       final result = await _storage.toggleSavedScan(scanId);
//       if (result) {
//         await loadInitialData();
//       }
//       return result;
//     } catch (error) {
//       print('Error toggling saved status: $error');
//       ScaffoldMessenger.of(_ref.context).showSnackBar(
//           SnackBar(content: Text('Failed to toggle saved status')));
//       return false;
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   Future<List<Car>> searchScans(String query) async {
//     try {
//       state = state.copyWith(isLoading: true);
//       final results = await _storage.searchScans(query);
//       return results.map((row) => Car.fromJson(row)).toList();
//     } catch (error) {
//       print('Error searching scans: $error');
//       return [];
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   String getRelativeTime(int timestamp) {
//     final now = DateTime.now().millisecondsSinceEpoch;
//     final diff = now - timestamp;
//     final minutes = (diff / 60000).floor();
//     final hours = (diff / 3600000).floor();
//     final days = (diff / 86400000).floor();
//     if (minutes < 60) return '$minutes min ago';
//     if (hours < 24) return '$hours h ago';
//     if (days < 30) return '$days d ago';
//     return DateFormat('yyyy-MM-dd')
//         .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
//   }

//   Future<void> createCollection(String name) async {
//     try {
//       if (state.user != null) {
//         final newCollection = await _firestore.collection('collections').add({
//           'userId': state.user!.uid,
//           'name': name,
//           'icon': '📁',
//           'cars': [],
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//         print('Successfully created collection: ${newCollection.id}');
//       } else {
//         final id = await _storage.createCollection(name, '📁');
//         final updatedCollections = await _storage.getCollections();
//         state = state.copyWith(collections: updatedCollections);
//       }
//     } catch (error) {
//       print('Error creating collection: $error');
//       ScaffoldMessenger.of(_ref.context)
//           .showSnackBar(SnackBar(content: Text('Failed to create collection')));
//     }
//   }

//   Future<void> addToCollection(
//       String collectionId, Map<String, dynamic> car) async {
//     try {
//       if (state.user != null) {
//         final collectionRef =
//             _firestore.collection('collections').doc(collectionId);
//         final collectionDoc = await collectionRef.get();
//         if (!collectionDoc.exists) {
//           print('Collection not found: $collectionId');
//           throw Exception('Collection not found');
//         }
//         final cleanCar = {
//           'car': car,
//           'addedAt': DateTime.now().toIso8601String(),
//         };
//         await collectionRef.update({
//           'cars': FieldValue.arrayUnion([cleanCar]),
//         });
//       } else {
//         await _storage.addToCollection(collectionId, car);
//         final updatedCollections = await _storage.getCollections();
//         state = state.copyWith(collections: updatedCollections);
//       }
//     } catch (error) {
//       print('Final error in addToCollection: $error');
//       ScaffoldMessenger.of(_ref.context).showSnackBar(
//           SnackBar(content: Text('Failed to add car to collection: $error')));
//     }
//   }

//   Future<void> removeFromCollection(String collectionId, String carId) async {
//     try {
//       if (state.user != null) {
//         final collectionRef =
//             _firestore.collection('collections').doc(collectionId);
//         final collection = (await collectionRef.get()).data();
//         final updatedCars =
//             collection!['cars'].where((car) => car['id'] != carId).toList();
//         await collectionRef.update({'cars': updatedCars});
//       } else {
//         await _storage.removeFromCollection(collectionId, carId);
//         final updatedCollections = await _storage.getCollections();
//         state = state.copyWith(collections: updatedCollections);
//       }
//     } catch (error) {
//       print('Error removing from collection: $error');
//     }
//   }

//   int get totalSavedCars {
//     final uniqueCarIds = <String>{};
//     state.collections.forEach((collection) {
//       collection['cars'].forEach((car) {
//         uniqueCarIds.add(car['id']);
//       });
//     });
//     return uniqueCarIds.length;
//   }

//   Future<bool> validateCollection(String collectionId) async {
//     if (state.user == null) return true;
//     try {
//       final doc =
//           await _firestore.collection('collections').doc(collectionId).get();
//       print('Collection data: ${doc.data()}');
//       return doc.exists;
//     } catch (error) {
//       print('Error validating collection: $error');
//       return false;
//     }
//   }

//   Future<void> deleteCollection(String collectionId) async {
//     try {
//       if (collectionId == '1') {
//         ScaffoldMessenger.of(_ref.context).showSnackBar(SnackBar(
//             content: Text('The Favorites collection cannot be deleted')));
//         return;
//       }
//       if (state.user != null) {
//         await _firestore.collection('collections').doc(collectionId).delete();
//         print('Successfully deleted Firestore collection: $collectionId');
//       } else {
//         await _storage.deleteCollection(collectionId);
//         final updatedCollections = await _storage.getCollections();
//         state = state.copyWith(collections: updatedCollections);
//       }
//     } catch (error) {
//       print('Error deleting collection: $error');
//       ScaffoldMessenger.of(_ref.context)
//           .showSnackBar(SnackBar(content: Text('Failed to delete collection')));
//     }
//   }
// }

/*
final dataProvider = Provider<DataProvider>((ref) {
  return DataProvider(ref);
});

class DataProvider {
  final WidgetRef _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();
  late User? _user;
  late List<Car> _recentScans;
  late List<Car> _savedCollection;
  late bool _isLoading;
  late bool _isInitialized;
  late bool _hasMore;
  late int _page;
  late List<Map<String, dynamic>> collections; // _collections
  late Map<String, int> _stats;
  late String _itemsPerPage = '20';

  DataProvider(this._ref);

  Future<void> init() async {
    _isLoading = true;
    await _storage.initDatabase();
    _isInitialized = true;
    final [initialScans, savedScans, loadedCollections, stats] =
        await Future.wait([
      _storage.getRecentScans(int.parse(_itemsPerPage), 0),
      _storage.getSavedCollection(),
      _storage.getCollections(),
      _storage.getStats(),
    ]);

    _recentScans = initialScans;
    _savedCollection = savedScans;
    _collections = loadedCollections;
    _stats = stats;
    _hasMore = initialScans.length == int.parse(_itemsPerPage);
    _isLoading = false;
  }

  void listenForAuthStateChanges() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _fetchCollections();
      } else {
        _fetchLocalCollections();
      }
    });
  }

  Future<void> _fetchCollections() async {
    try {
      final collectionsRef = _firestore.collection('collections');
      final snapshot =
          await collectionsRef.where('userId', isEqualTo: _user!.uid).get();

      if (snapshot.docs.isEmpty) {
        await collectionsRef.add({
          'userId': _user!.uid,
          'name': 'Favorites',
          'icon': '✨',
          'cars': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final collections = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'data': doc.data(),
              })
          .toList();

      _collections = collections;
    } catch (error) {
      print('Error fetching collections: $error');
    }
  }

  Future<void> _fetchLocalCollections() async {
    try {
      final localCollections = await _storage.getCollections();
      _collections = localCollections;
    } catch (error) {
      print('Error fetching local collections: $error');
    }
  }

  Future<void> loadInitialData() async {
    _page = 0;
    await loadData();
  }

  Future<void> loadData() async {
    if (!_isInitialized) return;
    try {
      _isLoading = true;
      final [scans, saved] = await Future.wait([
        _storage.getRecentScans(
            int.parse(_itemsPerPage), _page * int.parse(_itemsPerPage)),
        _storage.getSavedCollection(),
      ]);

      if (_page == 0) {
        _recentScans = scans;
      } else {
        _recentScans.addAll(scans);
      }

      _savedCollection = saved;
      _hasMore = scans.length == int.parse(_itemsPerPage);
    } catch (error) {
      print('Error loading data: $error');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading || !_isInitialized) return;
    _page++;
    await loadData();
  }

  Future<Car> saveScan(
      Map<String, dynamic> carInfo, String imageUri, String base64Image) async {
    if (!_isInitialized) throw Exception('Database not initialized');
    try {
      _isLoading = true;
      final scanId = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImageUri = await _storage.saveImage(base64Image, scanId);
      final newScan = Car(
        id: scanId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        carInfo: carInfo,
        images: [savedImageUri],
      );
      await _storage.saveScan(newScan.toJson());
      await loadInitialData();
      return newScan;
    } catch (error) {
      print('Error saving scan: $error');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> toggleSaved(String scanId) async {
    if (!_isInitialized) return false;
    try {
      _isLoading = true;
      final result = await _storage.toggleSavedScan(scanId);
      if (result) {
        await loadInitialData(); // Refresh data after toggle
      }
      return result;
    } catch (error) {
      print('Error toggling saved status: $error');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<Car>> searchScans(String query) async {
    try {
      _isLoading = true;
      final results = await _storage.searchScans(query);
      return results.map((row) => Car.fromJson(row)).toList();
    } catch (error) {
      print('Error searching scans: $error');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  String getRelativeTime(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;
    final minutes = (diff / 60000).floor();
    final hours = (diff / 3600000).floor();
    final days = (diff / 86400000).floor();

    if (minutes < 60) return '$minutes ago';
    if (hours < 24) return '$hours h ago';
    if (days < 30) return '$days d ago';
    return DateFormat('yyyy-MM-dd')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  Future<void> createCollection(String name) async {
    try {
      if (_user != null) {
        final newCollection = await _firestore.collection('collections').add({
          'userId': _user!.uid,
          'name': name,
          'icon': '📁',
          'cars': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Successfully created collection: ${newCollection.id}');
      } else {
        final id = await _storage.createCollection(name, '📁');
        final updatedCollections = await _storage.getCollections();
        _collections = updatedCollections;
      }
    } catch (error) {
      print('Error creating collection: $error');
      ScaffoldMessenger.of(_ref.context)
          .showSnackBar(SnackBar(content: Text('Failed to create collection')));
    }
  }

  Future<void> addToCollection(
      String collectionId, Map<String, dynamic> car) async {
    try {
      if (_user != null) {
        final collectionRef =
            _firestore.collection('collections').doc(collectionId);
        final collectionDoc = await collectionRef.get();
        if (!collectionDoc.exists) {
          print('Collection not found: $collectionId');
          throw Exception('Collection not found');
        }
        final cleanCar = {
          'car': car,
          'addedAt': DateTime.now().toIso8601String(),
        };
        await collectionRef.update({
          'cars': FieldValue.arrayUnion([cleanCar]),
        });
      } else {
        await _storage.addToCollection(collectionId, car);
        final updatedCollections = await _storage.getCollections();
        _collections = updatedCollections;
      }
    } catch (error) {
      print('Final error in addToCollection: $error');
      ScaffoldMessenger.of(_ref.context).showSnackBar(
          SnackBar(content: Text('Failed to add car to collection: $error')));
    }
  }

  Future<void> removeFromCollection(String collectionId, String carId) async {
    try {
      if (_user != null) {
        final collectionRef =
            _firestore.collection('collections').doc(collectionId);
        final collection = (await collectionRef.get()).data();
        final updatedCars =
            collection!['cars'].where((car) => car['id'] != carId).toList();
        await collectionRef.update({'cars': updatedCars});
      } else {
        await _storage.removeFromCollection(collectionId, carId);
        final updatedCollections = await _storage.getCollections();
        _collections = updatedCollections;
      }
    } catch (error) {
      print('Error removing from collection: $error');
    }
  }

  int get totalSavedCars {
    final uniqueCarIds = <String>{};
    _collections.forEach((collection) {
      collection['cars'].forEach((car) {
        uniqueCarIds.add(car['id']);
      });
    });
    return uniqueCarIds.length;
  }

  Future<bool> validateCollection(String collectionId) async {
    if (_user == null) return true;
    try {
      final doc =
          await _firestore.collection('collections').doc(collectionId).get();
      print('Collection data: ${doc.data()}');
      return doc.exists;
    } catch (error) {
      print('Error validating collection: $error');
      return false;
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      if (collectionId == '1') {
        ScaffoldMessenger.of(_ref.context).showSnackBar(SnackBar(
            content: Text('The Favorites collection cannot be deleted')));
        return;
      }
      if (_user != null) {
        await _firestore.collection('collections').doc(collectionId).delete();
        print('Successfully deleted Firestore collection: $collectionId');
      } else {
        await _storage.deleteCollection(collectionId);
        final updatedCollections = await _storage.getCollections();
        _collections = updatedCollections;
      }
    } catch (error) {
      print('Error deleting collection: $error');
      ScaffoldMessenger.of(_ref.context)
          .showSnackBar(SnackBar(content: Text('Failed to delete collection')));
    }
  }
}
*/
