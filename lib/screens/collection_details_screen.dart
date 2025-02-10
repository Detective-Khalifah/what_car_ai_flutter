import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/models/car_collection.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';
import 'package:what_car_ai_flutter/utils/time_utils.dart';
import 'package:what_car_ai_flutter/widgets/car_card.dart'; // For getRelativeTime

class CollectionDetailsScreen extends ConsumerStatefulWidget {
  final String collectionId;
  const CollectionDetailsScreen({super.key, required this.collectionId});

  @override
  _CollectionDetailsScreenState createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState
    extends ConsumerState<CollectionDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String? _collectionId;
  CarCollection? _collection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // _collectionId = ModalRoute.of(context)!.settings.arguments as String?;
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    // CarCollection collection;
    EasyLoading.show(status: 'Loading...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('collections')
            .doc(widget.collectionId)
            .get();
        if (docSnapshot.exists) {
          setState(() {
            _collection = CarCollection.fromFirestore(docSnapshot);
          });
        }
      } else {
        final localCollections = ref.watch(dataProvider).collections;
        final localCollection = localCollections
            .firstWhere((c) => (c as Car).id == widget.collectionId);
        if (localCollection != null) {
          setState(() {
            _collection = localCollection;
          });
        }
      }
    } catch (error) {
      print('Error fetching collection: $error');
    } finally {
      setState(() {
        _loading = false;
        EasyLoading.dismiss();
      });
    }
  }

  Future<void> _deleteCollection() async {
    EasyLoading.show(status: 'Deleting...');
    try {
      if (widget.collectionId == '1') {
        EasyLoading.showError('The Favorites collection cannot be deleted');
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('collections')
            .doc(widget.collectionId)
            .delete();
      } else {
        // Handle local storage deletion
      }

      EasyLoading.showSuccess('Collection deleted');
      context.pop();
    } catch (error) {
      EasyLoading.showError('Failed to delete collection: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection('collections')
            .doc(widget.collectionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Collection not found'));
          }

          final collection = CarCollection.fromFirestore(snapshot.data!);

          return Scaffold(
            appBar: AppBar(
              title: Text(collection.name),
              actions: [
                if (widget.collectionId != '1')
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(collection.name),
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  collection.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collection.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${collection.cars.length} ${collection.cars.length == 1 ? 'car' : 'cars'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cars Grid
                  Expanded(
                    child: ListView.builder(
                      itemCount: collection.cars.length,
                      itemBuilder: (context, index) {
                        final car = collection.cars[index];
                        return CarCard(
                          car: car.copyWith(
                            relativeTime: getRelativeTime(car.timestamp),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(String collectionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collection'),
        content: Text(
            'Are you sure you want to delete "$collectionName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteCollection(),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
