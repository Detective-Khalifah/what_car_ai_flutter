import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:what_car_ai_flutter/providers/ui/tab_state_provider.dart';
import 'package:what_car_ai_flutter/screens/garage_screens.dart';
import 'package:what_car_ai_flutter/screens/home_screen.dart';
import 'package:what_car_ai_flutter/screens/scan_screen.dart';

class TabsLayout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);
    final tabs = [
      HomeScreen(),
      ScanScreen(),
      GarageScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: CustomTabBar(ref: ref),
    );
  }
}

class CustomTabBar extends ConsumerWidget {
  final WidgetRef ref;

  CustomTabBar({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () =>
                ref.read(tabIndexProvider.notifier).update((state) => 0),
          ),
          _buildTabItem(
            icon: Icons.camera_alt,
            label: 'Scan',
            isSelected: currentIndex == 1,
            onTap: () =>
                ref.read(tabIndexProvider.notifier).update((state) => 1),
          ),
          _buildTabItem(
            icon: Icons.directions_car,
            label: 'My Whips',
            isSelected: currentIndex == 2,
            onTap: () =>
                ref.read(tabIndexProvider.notifier).update((state) => 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? Colors.purple /*violet*/ [500] : Colors.grey[600],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? Colors.purple /*violet*/ [500]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
