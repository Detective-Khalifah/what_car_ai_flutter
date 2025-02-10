import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';
import 'package:what_car_ai_flutter/utils/time_utils.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  bool _loading = false;
  int _page = 1;
  int _itemsPerPage = 15;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadScans();
    _isReady = true;
  }

  Future<void> _loadScans() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final scansSnapshot = await _firestore
            .collection('scans')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPage * _page)
            .get();
        final scans = scansSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'manufacturer': doc['manufacturer'],
                  'name': doc['name'],
                  'rarity': doc['rarity'],
                  'matchAccuracy': doc['matchAccuracy'],
                  'specs': doc['specs'],
                  'images': doc['images'],
                  'timestamp': doc['createdAt'].toDate(),
                })
            .toList();
        // ref.read(dataProvider.notifier).setRecentScans(scans); todo: fix error
      } else {
        // ref.read(dataProvider.notifier).setRecentScans([]); todo: fix error
      }
    } catch (error) {
      print('Error loading scans: $error');
    } finally {
      EasyLoading.dismiss();
      _loading = false;
    }
  }

  Future<void> _onRefresh() async {
    // _refreshController.requestRefresh();
    _page = 1;
    await _loadScans();
    // _refreshController.refreshCompleted();
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    _loading = true;
    _page++;
    await _loadScans();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final recentScans = ref
        .watch(dataProvider.select((data) => data.recentScans)); //.recentScans;
    final displayedScans = recentScans.take(_page * _itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => context.go('/scan'),
            color: Color(0xFF8B5CF6),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (displayedScans.isEmpty)
                _buildEmptyState()
              else
              // ...displayedScans.map((scan) => _buildScanCard(scan)).toList(),
              if (_loading)
                _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanCard(Car scan) {
    final rarityStyles = {
      'Ultra Rare': Colors.red,
      'Very Rare': Colors.orange,
      'Rare': Colors.yellow,
      'Uncommon': Colors.green,
      'Common': Colors.grey,
    };

    return GestureDetector(
      onTap: () => context.go('/details', extra: json.encode(scan)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (scan.images?.isNotEmpty == true)
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: CachedNetworkImage(
                  imageUrl: scan.images[0],
                  width: double.infinity,
                  height: 420,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Icon(
                    MdiIcons.car,
                    size: 48,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: rarityStyles[scan.rarity] ?? Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              scan.rarity.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                MdiIcons.checkCircle,
                                size: 16,
                                color: Color(0xFF22C55E),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${scan.matchAccuracy}% MATCH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Car Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.manufacturer,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            scan.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Stats Grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat('TOP SPEED',
                                  '${scan.specs?['topSpeed']} mph'),
                              _buildStat('0-60 MPH',
                                  '${scan.specs?['acceleration']} sec'),
                              _buildStat('POWER', '${scan.specs?['power']} hp'),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Timestamp
                          Row(
                            children: [
                              Icon(
                                Icons.schedule, // MdiIcons.schedule
                                size: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Scanned ${getRelativeTimePkg(DateTime.fromMillisecondsSinceEpoch(scan.timestamp))}", // todo: fix error
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors. /*violet*/ purple[100],
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.camera_alt,
              size: 48,
              color: Colors. /*violet*/ purple[600],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Cars Scanned Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start scanning cars to build your collection and see them appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/scan'),
            icon: Icon(Icons.add_a_photo, color: Colors.white, size: 20),
            label: Text(
              'Start Scanning',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors. /*violet*/ purple[600],
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Colors. /*violet*/ purple[600]!),
        ),
      ),
    );
  }
}
