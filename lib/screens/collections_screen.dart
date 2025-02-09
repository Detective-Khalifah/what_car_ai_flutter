import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final collectionsSnapshot = await _firestore
            .collection('collections')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();
        setState(() {
          _collections = collectionsSnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'name': doc['name'],
                    'icon': doc['icon'],
                    'cars': doc['cars'] ?? [],
                  })
              .toList();
        });
      } else {
        setState(() {
          _collections = ref.watch(dataProvider).collections.map((collection) {
            return {
              'id': collection.id,
              'name': collection.name,
              'icon': collection.icon,
              'cars': collection.cars.length, // Convert list of cars to count
            };
          }).toList();
        });
      }
    } catch (error) {
      print('Error fetching collections: $error');
    } finally {
      setState(() {
        _loading = false;
        EasyLoading.dismiss();
      });
    }
  }

  Future<void> _createCollection(String name) async {
    EasyLoading.show(status: 'Creating...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('collections').add({
          'userId': user.uid,
          'name': name,
          'icon': '📁',
          'cars': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        _loadCollections();
      } else {
        Fluttertoast.showToast(msg: 'Please log in to create a collection.');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to create collection: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateCollectionBottomSheet(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _collections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.collections_bookmark,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No collections yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showCreateCollectionBottomSheet(),
                          child: Text('Create Collection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors. /*violet*/ purple[100],
                            foregroundColor: Colors. /*violet*/ purple[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final collection = _collections[index];
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors. /*violet*/ purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              collection['icon'],
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          collection['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${collection['cars'].length} ${collection['cars'].length == 1 ? 'car' : 'cars'}',
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () =>
                            context.go('/collections/${collection['id']}'),
                      );
                    },
                  ),
      ),
    );
  }

  void _showCreateCollectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Collection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter collection name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(),
              onChanged: (value) {},
              onFieldSubmitted: (value) async {
                if (value.trim().isEmpty) {
                  Fluttertoast.showToast(
                      msg: 'Collection name cannot be empty.');
                  return;
                }
                await _createCollection(value.trim());
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final TextEditingController controller =
                          TextEditingController();
                      await showInputPanel(context /*, controller*/
                          );
                      if (controller.text.trim().isNotEmpty) {
                        await _createCollection(controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> showInputPanel(BuildContext context) async {
    TextEditingController _controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Collection'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter collection name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, _controller.text.trim());
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
