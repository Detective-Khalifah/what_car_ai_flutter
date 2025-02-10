import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/constants/driving_tips.dart';
import 'package:what_car_ai_flutter/constants/trending_cars.dart';
import 'package:what_car_ai_flutter/providers/car_provider.dart';
import 'package:what_car_ai_flutter/providers/firestore_stats.dart';
import 'package:what_car_ai_flutter/widgets/car_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreStats = ref.watch(firestoreStatsProvider);
    final carData = ref.watch(carDataProvider);
    final user = carData.user;
    final scans = carData.firestoreScans;
    final loading = carData.loading;
    final tipIndex = carData.tipIndex;
    final tip = DRIVING_TIPS[tipIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('What Car AI'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header Section
            Text(
              'Welcome back, ${user?.displayName ?? user?.email ?? 'Car Enthusiast'} 🚗',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              tip['message'],
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                      'Cars Identified',
                      '${carData.stats["totalScans"]}',
                      '+${carData.stats["weeklyScans"]} this week'),
                  _buildStat(
                      'Saved Cars',
                      '${firestoreStats.when(
                        data: (data) => data.totalSaved,
                        loading: () => 0,
                        error: (error, stackTrace) => 0,
                      )}',
                      '${carData.stats["newSaves"]} new saves'),
                ],
              ),
            ),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildQuickAction('Scan Car', Icons.camera, Color(0xFFEC4899),
                      () => context.go('/scan')),
                  _buildQuickAction('History', Icons.history, Color(0xFF6366F1),
                      () => context.go('/history')),
                  _buildQuickAction('Saved', Icons.bookmark, Color(0xFF3B82F6),
                      () => context.go('/collections')),
                  _buildQuickAction(
                      'Share',
                      Icons.share,
                      Color(0xFF10B981),
                      () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Coming Soon'),
                              content: Text(
                                  'Sharing feature will be available in the next update!'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
            // Recent Scans Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Scans',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton(
                          onPressed: () => context.go('/history'),
                          child: Text('See all'),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.camera),
                          SizedBox(height: 8),
                          if (loading && user != null)
                            CircularProgressIndicator()
                          else if (scans.isEmpty && user != null)
                            Text('No scans yet')
                          else if (scans.isNotEmpty)
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: scans.length,
                              itemBuilder: (context, index) {
                                final scan = scans[index];
                                return CarCard(car: scan);
                              },
                            )
                          else
                            Text('No recent scans'),
                          ElevatedButton(
                              onPressed: () {}, child: Text("Start scanning"))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Trending Cars
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trending Cars',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...List.generate(
                    TRENDING_CARS.length,
                    (index) => ListTile(
                      leading: Text('${index + 1}.'),
                      title: Text(TRENDING_CARS[index]['name']!),
                      subtitle: Text(TRENDING_CARS[index]['views']!),
                      trailing: Text('${TRENDING_CARS[index]['trend']}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, String additionalInfo) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(additionalInfo,
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickAction(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
