import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/providers/car_provider.dart';
import 'package:what_car_ai_flutter/providers/collection_provider.dart';
import 'package:what_car_ai_flutter/widgets/car_card.dart';
import 'package:what_car_ai_flutter/models/car_collection.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreScans = ref.watch(carDataProvider).firestoreScans;
    final loading = ref.watch(dataProvider).isLoading;
    final collections = ref.watch(dataProvider).collections;
    final stats = ref.watch(dataProvider).stats;

    String computeAverageAccuracy(List<Car> scans) {
      if (scans.isEmpty) return "0%";
      final totalAccuracy =
          scans.fold<double>(0, (sum, scan) => sum + scan.matchAccuracy);
      return '${(totalAccuracy / scans.length).round()}%';
    }

    final averageAccuracy = computeAverageAccuracy(firestoreScans);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Whips 📸'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identified & Saved',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'My Whips 📸',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat('This Week', stats.totalScans.toString(),
                      Icons.trending_up),
                  _buildQuickStat(
                      'Accuracy Rate', averageAccuracy, Icons.check_circle),
                  _buildQuickStat(
                      'Saved', stats.totalSaved.toString(), Icons.bookmark),
                ],
              ),
            ),
            // Recent Identifications
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Identifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (loading && user != null)
                    Center(child: CircularProgressIndicator())
                  else if (firestoreScans.isEmpty && user != null)
                    _buildEmptyState(
                      icon: Icons.camera_alt,
                      message: 'No identifications yet',
                      buttonText: 'Start Scanning',
                      onTap: () => context.go('/scan'),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: firestoreScans.length,
                        itemBuilder: (context, index) {
                          final scan = firestoreScans[index];
                          return CarCard(car: scan);
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Saved Collections
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Collections',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final CarCollection collection = collections[index];
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              collection.icon,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          collection.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${collection.cars.length} ${collection.cars.length == 1 ? 'car' : 'cars'}'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () =>
                            context.go('/collections/${collection.id}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple, size: 24),
        SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            child: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[100],
              foregroundColor: Colors.purple[600],
            ),
          ),
        ],
      ),
    );
  }
}

/*
class GarageScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final firestoreScans = ref.watch(firestoreScansProvider);
    final loading = ref.watch(loadingProvider);
    final collections = ref.watch(dataProvider).collections;
    final stats = ref.watch(dataProvider).stats;

    final averageAccuracy = useMemo(() {
      if (firestoreScans.isEmpty) return '0%';
      final total = firestoreScans.fold<double>(
          0, (sum, scan) => sum + scan['matchAccuracy'].toDouble());
      return '${(total / firestoreScans.length).round()}%';
    }, [firestoreScans]);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Whips 📸'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identified & Saved',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  Text(
                    'My Whips 📸',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat(
                      'This Week', stats.weeklyScans.toString(), 'trending-up'),
                  _buildQuickStat(
                      'Accuracy Rate', averageAccuracy, 'check-circle'),
                  _buildQuickStat(
                      'Saved', stats.totalSaved.toString(), 'bookmark'),
                ],
              ),
            ),
            // Recent Identifications
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Identifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (loading && user != null)
                    CircularProgressIndicator()
                  else if (firestoreScans.isEmpty && user != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 24, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No identifications yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/scan'),
                            child: Text('Start Scanning'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors. /*violet*/ purple[100],
                              foregroundColor: Colors. /*violet*/ purple[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: firestoreScans.length,
                        itemBuilder: (context, index) {
                          final scan = firestoreScans[index];
                          return CarCard(
                            car: Car.fromFirestore(scan),
                            // car: {
                            //   ...scan,
                            //   'relativeTime':
                            //       getRelativeTime(scan['timestamp']),
                            // },
                            // style: 'w-[280px]',
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Saved Collections
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Collections',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors. /*violet*/ purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              collection.icon /*['icon']*/,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          collection.name /*['name']*/,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${collection.cars /*['cars']*/ .length} ${collection.cars /*['cars']*/ .length == 1 ? 'car' : 'cars'}'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => context
                            .go('/collections/${collection.id /*['id']*/}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String count, String icon) {
    return Column(
      children: [
        Icon(MdiIcons.fromString(icon), color: Colors.white, size: 20),
        SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
        ),
      ],
    );
  }
}
*/
