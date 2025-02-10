import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:what_car_ai_flutter/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/details', extra: car),
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
            _buildCarImage(),
            _buildGradientOverlay(),
            _buildCarInfo(),
          ],
        ),
      ),
    );
  }

  /// 📌 Builds the car image with loading state
  Widget _buildCarImage() {
    return car.images.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              car.images.first,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            ),
          )
        : Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade900,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/car_icon.svg',
                color: Color(0xFF8B5CF6),
                height: 40,
              ),
            ),
          );
  }

  /// 🎨 Dark overlay with gradient effect
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black,
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  /// 🚀 Displays car details (rarity, manufacturer, power, etc.)
  Widget _buildCarInfo() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            _buildTopBar(),
            SizedBox(height: 8),
            // Car Info
            _buildManufacturerAndName(),
            SizedBox(height: 8),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  /// 🏆 Top Bar: Rarity + Match Accuracy
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getRarityColor(car.rarity),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            car.rarity.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: Color(0xFF22C55E),
            ),
            SizedBox(width: 4),
            Text(
              '${car.matchAccuracy ?? 0}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🚘 Manufacturer & Car Name
  Widget _buildManufacturerAndName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          car.manufacturer,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          car.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 🔥 Stats Row: Power | 0-60 MPH | Scanned Time
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStat('POWER', '${car.power ?? '--'} hp'),
        _buildStat('0-60 MPH', '${car.acceleration ?? '--'}s'),
        _buildStat('SCANNED', car.relativeTime ?? '--'),
        // _buildStat('POWER', car.power ?? '-- hp'),
        // _buildStat('0-60 MPH', car.acceleration ?? '--s'),
        // _buildStat('SCANNED', car.relativeTime),
      ],
    );
  }

  /// 📊 Generic Stat Widget
  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 🎨 Determines the color of the rarity badge
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Ultra Rare':
        return Color(0xFFDC2626);
      case 'Very Rare':
        return Color(0xFFF97316);
      case 'Rare':
        return Color(0xFFEAB308);
      case 'Uncommon':
        return Color(0xFF22C55E);
      default:
        return Color(0xFFA0AEC0);
    }
  }
}
