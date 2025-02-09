import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:what_car_ai_flutter/contexts/data_context.dart';
// import 'package:what_car_ai_flutter/components/car_card.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/models/car_collection.dart';
import 'package:what_car_ai_flutter/providers/car_provider.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';
// import 'package:what_car_ai_flutter/providers/data_provider.dart';
// import 'package:what_car_ai_flutter/utils/utilities.dart';
import 'package:what_car_ai_flutter/widgets/car_card.dart'; // For getRelativeTime

class CollectionDetailsScreen extends ConsumerStatefulWidget {
  @override
  _CollectionDetailsScreenState createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState
    extends ConsumerState<CollectionDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _collectionId;
  CarCollection? _collection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _collectionId = ModalRoute.of(context)!.settings.arguments as String?;
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('collections').doc(_collectionId).get();
        if (docSnapshot.exists) {
          setState(() {
            _collection = CarCollection.fromFirestore(docSnapshot);
          });
        }
      } else {
        final localCollections = ref.watch(dataProvider).collections;
        final localCollection = localCollections
            .firstWhere /*OrNull*/ ((c) => (c as Car).id == _collectionId);
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
      if (_collectionId == '1') {
        EasyLoading.showError('The Favorites collection cannot be deleted');
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('collections').doc(_collectionId).delete();
      } else {
        // Handle local storage deletion
      }

      EasyLoading.showSuccess('Collection deleted');
      Navigator.pop(context);
    } catch (error) {
      EasyLoading.showError('Failed to delete collection: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_collection != null ? _collection!.name /*['name']*/ : ''),
        actions: [
          if (_collection != null && _collectionId != '1')
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmationDialog(),
              color: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _collection == null
              ? Center(child: Text('Collection not found'))
              : Padding(
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
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _collection!.icon /*['icon']*/,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _collection!.name /*['name']*/,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${_collection!.cars /*['cars']*/ ?.length ?? 0} ${(_collection!.cars /*['cars']*/ ?.length ?? 0) == 1 ? 'car' : 'cars'}',
                                      style: TextStyle(color: Colors.grey),
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
                          itemCount:
                              _collection!.cars /*['cars']*/ ?.length ?? 0,
                          itemBuilder: (context, index) {
                            final car = _collection!.cars /*['cars']*/ [index];
                            return CarCard(
                              car: car,
                              // Car.fromFirestore(car)

                              //  {...car,
                              //   'relativeTime':
                              //       getRelativeTime(car['timestamp']),
                              // style: 'w-full',},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collection'),
        content: Text(
            'Are you sure you want to delete "${_collection!.name /*['name']*/}"? This action cannot be undone.'),
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
